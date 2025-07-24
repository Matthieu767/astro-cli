import os
import shutil
from datetime import datetime
import pandas as pd
from dagster import asset, AssetExecutionContext, DailyPartitionsDefinition, Output
from dagster_dbt import dbt_assets, DbtCliResource
import sqlite3
from deltalake import write_deltalake
from deltalake import DeltaTable

# Partitioning by date (YYYY-MM-DD)
partitions_def = DailyPartitionsDefinition(start_date="2024-01-01")

# Get the project root directory (where dbt_project.yml is located)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BRONZE_SRC = os.path.join(PROJECT_ROOT, "data", "bronze")
BRONZE_PART = os.path.join(PROJECT_ROOT, "data", "bronze", "{partition}")
SILVER_PART = os.path.join(PROJECT_ROOT, "data", "silver", "{partition}")
GOLD_PATH = os.path.join(PROJECT_ROOT, "data", "gold")
WAREHOUSE = os.path.join(PROJECT_ROOT, "data", "warehouse.db")

@asset(partitions_def=partitions_def)
def bronze_items_partitioned(context: AssetExecutionContext) -> Output[str]:
    partition = context.partition_key
    src = os.path.join(BRONZE_SRC, "items.csv")
    dest_dir = BRONZE_PART.format(partition=partition)
    os.makedirs(dest_dir, exist_ok=True)
    dest = os.path.join(dest_dir, "items.csv")
    shutil.copy(src, dest)
    context.log.info(f"Copied items.csv to {dest}")
    return Output(dest, metadata={"partition": partition})

@asset(partitions_def=partitions_def)
def bronze_attributes_partitioned(context: AssetExecutionContext) -> Output[str]:
    partition = context.partition_key
    src = os.path.join(BRONZE_SRC, "attributes.csv")
    dest_dir = BRONZE_PART.format(partition=partition)
    os.makedirs(dest_dir, exist_ok=True)
    dest = os.path.join(dest_dir, "attributes.csv")
    shutil.copy(src, dest)
    context.log.info(f"Copied attributes.csv to {dest}")
    return Output(dest, metadata={"partition": partition})

@asset(partitions_def=partitions_def, deps=["bronze_items_partitioned", "bronze_attributes_partitioned"])
def load_bronze_to_sqlite(context: AssetExecutionContext) -> Output[None]:
    partition = context.partition_key
    context.log.info(f"Loading bronze data to SQLite for partition: {partition}")
    
    # Connect to SQLite database
    conn = sqlite3.connect(WAREHOUSE)
    
    # Load items data
    items_path = os.path.join(BRONZE_PART.format(partition=partition), "items.csv")
    items_df = pd.read_csv(items_path, delimiter=';')
    items_df.to_sql('bronze_items_source', conn, if_exists='replace', index=False)
    context.log.info(f"Loaded {len(items_df)} items to SQLite")
    
    # Load attributes data
    attributes_path = os.path.join(BRONZE_PART.format(partition=partition), "attributes.csv")
    attributes_df = pd.read_csv(attributes_path, delimiter=';')
    attributes_df.to_sql('bronze_attributes_source', conn, if_exists='replace', index=False)
    context.log.info(f"Loaded {len(attributes_df)} attributes to SQLite")
    
    conn.close()
    return Output(None, metadata={"partition": partition, "load_status": "completed"})

@asset(partitions_def=partitions_def, deps=["load_bronze_to_sqlite"])
def run_dbt_transformations(context: AssetExecutionContext) -> Output[None]:
    partition = context.partition_key
    context.log.info(f"Running dbt transformations for partition: {partition}")
    
    # Initialize dbt CLI resource
    dbt = DbtCliResource(project_dir=PROJECT_ROOT)
    
    # Run dbt models (bronze, silver, and gold layers)
    context.log.info("Running dbt bronze, silver, and gold models...")
    result = dbt.cli(
        ["run", "--models", "bronze_items bronze_attributes silver_items silver_attributes silver_values gold_items gold_attributes gold_values", "--vars", f'{{"partition_date": "{partition}"}}']
    )
    
    context.log.info(f"dbt run completed for partition: {partition}")
    return Output(None, metadata={"partition": partition, "dbt_status": "completed"})

@asset(partitions_def=partitions_def, deps=["run_dbt_transformations"])
def convert_gold_to_delta(context: AssetExecutionContext) -> Output[None]:
    partition = context.partition_key
    context.log.info(f"Converting gold layer to Delta Lake format for partition: {partition}")
    
    # Create gold directory if it doesn't exist
    os.makedirs(GOLD_PATH, exist_ok=True)
    
    # Connect to SQLite database
    conn = sqlite3.connect(WAREHOUSE)
    
    # Convert each gold table to Delta Lake format
    gold_tables = ["gold_items", "gold_attributes", "gold_values"]
    
    for table_name in gold_tables:
        # Query the gold table
        query = f"SELECT * FROM {table_name}"
        df = pd.read_sql_query(query, conn)
        
        # Convert to Delta Lake format
        delta_table_path = os.path.join(GOLD_PATH, table_name.replace('gold_', ''))
        
        # Use merge to only write actual changes
        try:
            # Try to load existing Delta table
            dt = DeltaTable(delta_table_path)
            
            # Merge new data with existing data
            # For values table, merge on item_id and attribute_id
            if table_name == "gold_values":
                merge_condition = "item_id = source.item_id AND attribute_id = source.attribute_id"
            elif table_name == "gold_items":
                merge_condition = "id = source.id"
            else:  # gold_attributes
                merge_condition = "id = source.id"
            
            # Create merge operation
            merger = dt.merge(
                df,
                merge_condition,
                source_alias="source",
                target_alias="target"
            )
            
            # Execute merge with update and insert actions
            merger.when_matched_update_all().when_not_matched_insert_all().execute()
            
            context.log.info(f"Merged {table_name} to Delta Lake at {delta_table_path} with {len(df)} rows")
            
        except Exception as e:
            # If table doesn't exist or other error, create it with initial data
            context.log.info(f"Creating new Delta table for {table_name}: {e}")
            write_deltalake(
                delta_table_path,
                df,
                mode="overwrite"  # Overwrite to handle any existing files
            )
            context.log.info(f"Created new {table_name} Delta Lake table at {delta_table_path} with {len(df)} rows")
    
    conn.close()
    return Output(None, metadata={"partition": partition, "delta_conversion": "completed"})

@asset(partitions_def=partitions_def, deps=["run_dbt_transformations"])
def export_silver_to_csv(context: AssetExecutionContext) -> None:
    partition = context.partition_key
    silver_dir = SILVER_PART.format(partition=partition)
    os.makedirs(silver_dir, exist_ok=True)
    
    # Connect to SQLite database
    conn = sqlite3.connect(WAREHOUSE)
    
    # Export silver tables to CSV
    tables = ["silver_items", "silver_attributes", "silver_values"]
    
    for table_name in tables:
        # Query the table
        query = f"SELECT * FROM {table_name}"
        df = pd.read_sql_query(query, conn)
        
        # Export to CSV
        csv_path = os.path.join(silver_dir, f"{table_name.replace('silver_', '')}.csv")
        df.to_csv(csv_path, index=False)
        context.log.info(f"Exported {table_name} to {csv_path} with {len(df)} rows")
    
    conn.close()

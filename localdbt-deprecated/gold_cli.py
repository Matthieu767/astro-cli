#!/usr/bin/env python3
"""
Gold Layer CLI
Simple CLI to query Delta Lake gold data using Typer framework.
"""

import os
import typer
from typing import Optional
from deltalake import DeltaTable
import pandas as pd
from datetime import datetime, timedelta
import pyarrow as pa

app = typer.Typer(help="Gold Layer Delta Lake CLI")

def get_gold_path() -> str:
    """Get the path to the gold layer data"""
    project_root = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(project_root, "data", "gold")

def get_available_tables() -> list[str]:
    """Get list of available Delta tables"""
    gold_path = get_gold_path()
    
    if not os.path.exists(gold_path):
        return []
    
    tables = []
    for item in os.listdir(gold_path):
        item_path = os.path.join(gold_path, item)
        if os.path.isdir(item_path) and not item.startswith('_'):
            tables.append(item)
    
    return tables

def get_available_versions(table_name: str) -> list[dict]:
    """Get available versions for a Delta table"""
    try:
        gold_path = get_gold_path()
        table_path = os.path.join(gold_path, table_name)
        dt = DeltaTable(table_path)
        return dt.history()
    except Exception:
        return []

def read_delta_version(table_path: str, version: int) -> pd.DataFrame:
    """Read a specific version of a Delta table"""
    try:
        # Use the correct method to read specific version
        dt = DeltaTable(table_path, version=version)
        return dt.to_pandas()
    except Exception as e:
        raise Exception(f"Failed to read version {version}: {e}")

@app.command()
def list_tables():
    """List all available tables in the gold layer"""
    tables = get_available_tables()
    
    if not tables:
        typer.echo("❌ No Delta tables found in gold layer.")
        typer.echo("Run the Dagster pipeline first to create gold layer data.")
        raise typer.Exit(1)
    
    typer.echo("📋 Available tables:")
    for table in tables:
        typer.echo(f"  • {table}")

@app.command()
def show(
    table: str = typer.Argument(..., help="Table name to query"),
    limit: int = typer.Option(10, "--limit", "-l", help="Number of rows to show (default: 10)"),
    partition_date: Optional[str] = typer.Option(None, "--partition", "-p", help="Partition date (YYYY-MM-DD) for time travel")
):
    """Show the first N items from a table"""
    
    # Check if table exists
    tables = get_available_tables()
    if not tables:
        typer.echo("❌ No Delta tables found in gold layer.")
        typer.echo("Run the Dagster pipeline first to create gold layer data.")
        raise typer.Exit(1)
    
    if table not in tables:
        typer.echo(f"❌ Table '{table}' not found.")
        typer.echo(f"Available tables: {', '.join(tables)}")
        raise typer.Exit(1)
    
    # Load and query the table
    try:
        gold_path = get_gold_path()
        table_path = os.path.join(gold_path, table)
        
        # Get data based on partition date
        if partition_date:
            # Validate partition date format
            try:
                datetime.strptime(partition_date, "%Y-%m-%d")
            except ValueError:
                typer.echo(f"❌ Invalid partition date format: {partition_date}")
                typer.echo("Use format: YYYY-MM-DD (e.g., 2025-02-01)")
                raise typer.Exit(1)
            
            # Get available versions
            versions = get_available_versions(table)
            if not versions:
                typer.echo(f"❌ No versions available for table '{table}'")
                raise typer.Exit(1)
            
            # Find version that contains the partition date
            target_version = None
            for version in versions:
                try:
                    # Load data from this version
                    df_version = read_delta_version(table_path, version['version'])
                    if 'partition_date' in df_version.columns:
                        if partition_date in df_version['partition_date'].values:
                            target_version = version['version']
                            break
                except Exception:
                    # Skip versions that can't be read
                    continue
            
            if target_version is None:
                typer.echo(f"❌ No data found for partition date: {partition_date}")
                typer.echo("Available partition dates:")
                # Show available partition dates from latest version
                try:
                    df_latest = DeltaTable(table_path).to_pandas()
                    if 'partition_date' in df_latest.columns:
                        available_dates = sorted(df_latest['partition_date'].unique())
                        for date in available_dates:
                            typer.echo(f"  • {date}")
                except Exception:
                    typer.echo("  (Unable to retrieve available dates)")
                raise typer.Exit(1)
            
            # Load data from specific version
            df = read_delta_version(table_path, target_version)
            typer.echo(f"🕒 Time travel: Querying {table} from partition {partition_date} (version {target_version})")
            
        else:
            # Get latest data
            dt = DeltaTable(table_path)
            df = dt.to_pandas()
            typer.echo(f"📊 Querying {table} (latest version)")
        
        if len(df) == 0:
            typer.echo(f"📊 Table '{table}' is empty")
            return
        
        # Filter by partition date if specified
        if partition_date and 'partition_date' in df.columns:
            df = df[df['partition_date'] == partition_date]
            if len(df) == 0:
                typer.echo(f"📊 No data found for partition date: {partition_date}")
                return
        
        # Show first N rows
        result = df.head(limit)
        total_rows = len(df)
        shown_rows = len(result)
        
        if partition_date:
            typer.echo(f"📊 First {shown_rows} rows from '{table}' partition {partition_date} (total: {total_rows} rows):")
        else:
            typer.echo(f"📊 First {shown_rows} rows from '{table}' (total: {total_rows} rows):")
        
        typer.echo(result.to_string(index=False))
        
    except Exception as e:
        typer.echo(f"❌ Error querying table '{table}': {e}")
        raise typer.Exit(1)

@app.command()
def info(table: str = typer.Argument(..., help="Table name to get info about")):
    """Show information about a table (schema and row count)"""
    
    # Check if table exists
    tables = get_available_tables()
    if not tables:
        typer.echo("❌ No Delta tables found in gold layer.")
        typer.echo("Run the Dagster pipeline first to create gold layer data.")
        raise typer.Exit(1)
    
    if table not in tables:
        typer.echo(f"❌ Table '{table}' not found.")
        typer.echo(f"Available tables: {', '.join(tables)}")
        raise typer.Exit(1)
    
    try:
        gold_path = get_gold_path()
        table_path = os.path.join(gold_path, table)
        dt = DeltaTable(table_path)
        
        # Get schema
        schema = dt.schema()
        
        # Get data for row count
        df = dt.to_pandas()
        
        # Get available versions
        versions = get_available_versions(table)
        
        typer.echo(f"📋 Table: {table}")
        typer.echo(f"📊 Rows: {len(df)}")
        typer.echo(f"🕒 Versions: {len(versions)}")
        
        if versions:
            typer.echo("📅 Available partition dates:")
            if 'partition_date' in df.columns:
                available_dates = sorted(df['partition_date'].unique())
                for date in available_dates:
                    typer.echo(f"  • {date}")
        
        typer.echo("🔧 Schema:")
        for field in schema.fields:
            typer.echo(f"  • {field.name}: {field.type}")
        
    except Exception as e:
        typer.echo(f"❌ Error getting info for table '{table}': {e}")
        raise typer.Exit(1)

@app.command()
def versions(table: str = typer.Argument(..., help="Table name to show versions for")):
    """Show available versions for a table"""
    
    # Check if table exists
    tables = get_available_tables()
    if not tables:
        typer.echo("❌ No Delta tables found in gold layer.")
        typer.echo("Run the Dagster pipeline first to create gold layer data.")
        raise typer.Exit(1)
    
    if table not in tables:
        typer.echo(f"❌ Table '{table}' not found.")
        typer.echo(f"Available tables: {', '.join(tables)}")
        raise typer.Exit(1)
    
    try:
        versions = get_available_versions(table)
        
        if not versions:
            typer.echo(f"❌ No versions available for table '{table}'")
            raise typer.Exit(1)
        
        typer.echo(f"🕒 Versions for {table}:")
        for version in versions:
            typer.echo(f"  • Version {version['version']}: {version['timestamp']}")
        
    except Exception as e:
        typer.echo(f"❌ Error getting versions for table '{table}': {e}")
        raise typer.Exit(1)

@app.command()
def diff():
    """Compare values table between last two versions using native Delta Lake CDF"""
    
    try:
        gold_path = get_gold_path()
        table_path = os.path.join(gold_path, "values")
        dt = DeltaTable(table_path)
        
        # Get available versions
        versions = dt.history()
        if len(versions) < 2:
            typer.echo("❌ Need at least 2 versions to compare")
            raise typer.Exit(1)
        
        # Always compare the last two versions
        latest_version = versions[0]['version']
        previous_version = versions[1]['version']
        
        # Use CDF to get changes between the last two versions
        try:
            # Load Change Data Feed
            cdf_reader = dt.load_cdf(
                starting_version=previous_version,
                ending_version=latest_version
            )
            
            # Count all changes (not filtered by partitions)
            change_counts = {}
            total_changes = 0
            
            try:
                while True:
                    batch = cdf_reader.read_next_batch()
                    if batch is None:
                        break
                    
                    # Process each batch directly
                    num_rows = batch.num_rows
                    for i in range(num_rows):
                        change_type = batch.column('_change_type')[i].as_py()
                        
                        # Count all changes
                        change_counts[change_type] = change_counts.get(change_type, 0) + 1
                        total_changes += 1
                            
            except StopIteration:
                pass
            
            # Display results
            typer.echo(f"🔄 Changes in latest version ({previous_version} → {latest_version})")
            typer.echo(f"📊 Total changes: {total_changes}")
            
            if change_counts:
                typer.echo("📈 Breakdown:")
                for change_type, count in change_counts.items():
                    typer.echo(f"  • {change_type}: {count}")
            else:
                typer.echo("📊 No changes found")
            
        except Exception as cdf_error:
            typer.echo(f"⚠️  CDF not available: {cdf_error}")
            raise typer.Exit(1)
        
    except Exception as e:
        typer.echo(f"❌ Error comparing versions: {e}")
        raise typer.Exit(1)

if __name__ == "__main__":
    app() 
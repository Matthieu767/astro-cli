# Bronze-Silver-Gold Data Pipeline

A data pipeline built with **Dagster** and **dbt** that transforms raw CSV data from bronze layer to silver layer using SQLite, and then to gold layer using Delta Lake for time travel capabilities.

## 🏗️ Architecture

This project implements a **bronze-silver-gold data architecture**:

- **Bronze Layer**: Raw CSV data (items and attributes)
- **Silver Layer**: Cleaned and transformed data (SQLite)
- **Gold Layer**: Business-ready data with time travel (Delta Lake)
- **Orchestration**: Dagster for pipeline management
- **Transformation**: dbt for SQL-based data transformations
- **Storage**: SQLite database for middle data operations, Delta Lake for gold layer

## 📁 Project Structure

```
localdbt/
├── bronze_silver_pipeline/          # Dagster pipeline package
│   └── bronze_silver_pipeline/
│       ├── assets.py               # Pipeline assets and transformations
│       └── definitions.py          # Dagster definitions
├── data/
│   ├── bronze/                     # Raw CSV data (partitioned by date)
│   │   ├── items.csv              # Source items data
│   │   ├── attributes.csv         # Source attributes data
│   │   └── YYYY-MM-DD/            # Partitioned data folders
│   ├── silver/                     # Transformed data (partitioned by date)
│   ├── gold/                       # Delta Lake gold layer data
│   │   ├── items/                 # Delta table for items
│   │   ├── attributes/            # Delta table for attributes
│   │   ├── values/                # Delta table for values
│   │   └── _delta_log/            # Delta Lake metadata
│   └── warehouse.db               # SQLite data warehouse
├── models/                         # dbt transformation models
│   ├── bronze_attributes.sql      # Bronze attributes model
│   ├── bronze_items.sql           # Bronze items model
│   ├── silver_attributes.sql      # Silver attributes model
│   ├── silver_items.sql           # Silver items model
│   ├── silver_values.sql          # Silver values model
│   ├── gold/                      # Gold layer models
│   │   ├── gold_items.sql         # Gold items model (SQLite)
│   │   ├── gold_attributes.sql    # Gold attributes model (SQLite)
│   │   └── gold_values.sql        # Gold values model (SQLite)
│   └── sources/
│       └── bronze.yml             # Source definitions
├── dbt_project.yml                # dbt project configuration
├── profiles.yml                   # dbt database profiles
├── requirements.txt               # Python dependencies
├── gold_cli.py                    # Gold layer CLI tool (Typer)
└── workspace.yaml                 # Dagster workspace configuration
```

## 🚀 Installation

### Prerequisites

- Python 3.9-3.12
- pip (Python package manager)

### Setup

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd localdbt
   ```

2. **Create and activate virtual environment**:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Install the Dagster pipeline package**:
   ```bash
   pip install -e ./bronze_silver_pipeline
   ```

## 🏃‍♂️ Running the Pipeline

### Using Dagster UI (Recommended)

1. **Start Dagster development server**:
   ```bash
   dagster dev --workspace workspace.yaml
   ```

2. **Open your browser** and navigate to:
   ```
   http://localhost:3000
   ```

3. **Navigate to Assets** and trigger the pipeline:
   - Go to "Assets" tab
   - Select the assets you want to run
   - Click "Materialize" to execute the pipeline

### Manual dbt execution (for development)

```bash
# Run all models (bronze, silver, and gold)
dbt run

# Run with specific partition
dbt run --vars '{"partition_date": "2025-02-01"}'

# Example: Run specific layers
dbt run --models bronze_items bronze_attributes silver_items silver_attributes silver_values gold_items gold_attributes gold_values --vars '{"partition_date": "2025-02-01"}'

# Test your models
dbt test

# Generate documentation (specify a partition date)
dbt docs generate --vars '{"partition_date": "2025-02-01"}'
dbt docs serve
```

## 📊 Pipeline Flow

The pipeline follows this automated sequence:

1. **Data Partitioning**: CSV files are copied to date-partitioned folders
2. **Bronze Loading**: Raw data is loaded into SQLite tables
3. **dbt Transformations**: SQL models transform bronze to silver and gold data
4. **Delta Lake Conversion**: Gold layer data is converted to Delta Lake format
5. **Silver Export**: Transformed data is exported back to CSV files

### Assets in Order:

1. `bronze_items_partitioned` → Copies items CSV to partitioned folder
2. `bronze_attributes_partitioned` → Copies attributes CSV to partitioned folder
3. `load_bronze_to_sqlite` → Loads CSV data into SQLite tables
4. `run_dbt_transformations` → Executes dbt models (bronze, silver, gold)
5. `convert_gold_to_delta` → Converts gold layer to Delta Lake format
6. `export_silver_to_csv` → Exports transformed data to CSV

## 🔧 Configuration

### Database Configuration

The project uses multiple storage systems as configured in `profiles.yml`:
- **SQLite**: `warehouse.db` in the `data/` folder for bronze/silver/gold layers
- **Delta Lake**: `data/gold/` folder for gold layer with time travel

### Delta Lake Configuration

The gold layer uses Delta Lake with:
- **ACID transactions** for data consistency
- **Time travel** capabilities for historical data access
- **Schema evolution** support
- **Merge operations** for efficient change tracking
- **Version-based time travel** (no partitioning)

## 📈 Data Models

### Bronze Models
- `bronze_items`: Raw items data
- `bronze_attributes`: Raw attributes data

### Silver Models
- `silver_items`: Cleaned items data
- `silver_attributes`: Cleaned attributes data
- `silver_values`: Aggregated values data

### Gold Models
- `gold_items`: Business-ready items data (SQLite → Delta Lake)
- `gold_attributes`: Business-ready attributes data (SQLite → Delta Lake)
- `gold_values`: Business-ready values data (SQLite → Delta Lake)

## 🐤 Gold Layer CLI

Query your gold layer data using the Typer-based CLI with time travel capabilities:

### List Available Tables

```bash
python gold_cli.py list-tables
```

### Show First 10 Items from a Table

```bash
# Show first 10 items (default)
python gold_cli.py show items

# Show first 5 items
python gold_cli.py show items --limit 5

# Show first 20 items
python gold_cli.py show values --limit 20
```

### Show Latest Data

```bash
# Show latest data from a table
python gold_cli.py show items

# Show latest data with custom limit
python gold_cli.py show values --limit 5

# Show latest data from different table
python gold_cli.py show attributes
```

### Get Table Information

```bash
# Show table schema, row count, and available versions
python gold_cli.py info items
python gold_cli.py info attributes
python gold_cli.py info values
```

### Show Available Versions

```bash
# Show all available versions for a table
python gold_cli.py versions items
python gold_cli.py versions values
```

### Compare Versions (Diff)

```bash
# Compare changes between last two versions using native Delta Lake CDF
python gold_cli.py diff
```

### CLI Features

- **Simple Commands**: Easy-to-use Typer-based interface
- **Table Exploration**: List tables and get schema information
- **Data Preview**: Show first N rows from any table
- **Version-based Time Travel**: Query data from specific Delta Lake versions
- **Version History**: View available versions and timestamps
- **Change Tracking**: Compare changes between versions using CDF
- **Error Handling**: Clear error messages and helpful suggestions
- **Auto-completion**: Typer provides command auto-completion

### Example Usage

```bash
# List all available tables
python gold_cli.py list-tables

# Show first 10 items from items table
python gold_cli.py show items

# Show first 5 values
python gold_cli.py show values --limit 5

# Get info about attributes table (shows available versions)
python gold_cli.py info attributes

# Show available versions
python gold_cli.py versions items

# Compare changes between versions
python gold_cli.py diff
```

### Time Travel Features

The CLI leverages Delta Lake's time travel capabilities to:

- **Query Historical Data**: Access data as it existed at specific versions
- **Version-based Queries**: Filter data by Delta Lake version number
- **Version Tracking**: See which Delta Lake version contains the data
- **Data Consistency**: Ensure you're querying the exact state of data at that time
- **Change Data Feed**: Track actual changes between versions using CDF

## 🛠️ Development

### Adding New Models

1. Create new SQL files in the appropriate `models/` directory
2. Update the Dagster asset to include new models in the dbt run command
3. Test with `dbt run --models <model_name>`

### Adding New Data Sources

1. Add source definitions in `models/sources/bronze.yml`
2. Create corresponding models in `models/`
3. Update the Dagster pipeline assets

## 🐛 Troubleshooting

### Common Issues

1. **Database not found**: Ensure `data/warehouse.db` exists
2. **Partition errors**: Check that source CSV files exist in `data/bronze/`
3. **dbt errors**: Run `dbt debug` to check configuration
4. **Delta Lake errors**: Ensure `deltalake` and `pyarrow` are installed

### Logs

- Dagster logs are available in the UI
- dbt logs are generated in the `target/` directory (auto-created)

## 📝 Dependencies

### Core Dependencies
- `dagster`: Orchestration framework
- `dagster-dbt`: dbt integration for Dagster
- `dbt-core`: Core dbt functionality
- `dbt-sqlite`: SQLite adapter for dbt
- `pandas`: Data manipulation
- `deltalake`: Delta Lake Python library
- `pyarrow`: Arrow format support for Delta Lake
- `typer`: CLI framework

### Development Dependencies
- `dagster-webserver`: Dagster UI
- `pytest`: Testing framework

# Data Flow Infrastructure

This repository contains Terraform configurations for managing a data flow infrastructure on Google Cloud Platform (GCP) using the medallion architecture pattern.

## Architecture Overview

The infrastructure follows an environment-based architecture with clear separation of concerns:

```
infra/
├── main.tf                    # Main orchestration (references dev environment)
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── backend.tf                 # State backend configuration
├── providers.tf               # Provider configuration
├── terraform.tfvars.example   # Example configuration
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   │   ├── data/              # Data layer (moved from layers/data/)
│   │   ├── variables.tf       # Environment variables
│   │   └── terraform.tfvars   # Environment values
│   ├── qa/                    # QA environment (placeholder)
│   └── prod/                  # Production environment (placeholder)
└── modules/                   # Reusable modules
```

## Data Flow

### Data Layer (`environments/dev/data/`)
**Purpose**: Raw data ingestion from various sources

```
environments/dev/data/
├── datasources.tf    # Datasource module instantiations (midocean etc)
├── roles.tf          # Custom IAM roles for data access
├── outputs.tf        # Exposes role names
└── variables.tf      # Layer variables
```

**Components**:
- **Datasources**: Each datasource creates a storage bucket (and other resources later)
- **IAM Roles**: Custom `dataDatasourcesEditor` role for developer access
- **Current Datasources**: 
  - `midocean` → `source-midocean` bucket
  - `test` → `source-test` bucket

## Reusable Modules

### Datasource Module (`modules/datasource/`)
**Purpose**: Reusable module for creating data sources with consistent configuration

```
modules/datasource/
├── variables.tf    # Module variables (project_id, name, region, developer_emails, data_editor_role)
├── outputs.tf      # Exposes bucket_name
├── buckets.tf      # Google Storage bucket resource
└── iam.tf          # Developer access to the bucket
```

**Features**:
- **Storage Bucket**: Named `source-{name}` with lifecycle rules
- **Automatic IAM**: Developers get access when datasource is created
- **Scalable**: Add new datasources without manual IAM configuration

## IAM Architecture

### Role Definition
- **Location**: `environments/dev/data/roles.tf`
- **Role**: `dataDatasourcesEditor`
- **Permissions**: Full CRUD operations on data layer buckets

### Access Management
- **Developer Emails**: Configured at root level in `variables.tf`
- **Automatic Assignment**: Each datasource module grants access to its bucket
- **Scope**: Limited to data layer buckets only

## Configuration

### Required Variables
```hcl
project_id = "datamanagemenplatformdev"
```

### Optional Variables
```hcl
region = "europe-west3"  # Default region
developer_emails = [     # Developer access
  "developer1@company.com",
  "developer2@company.com"
]
```

### Example Configuration
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Adding New Datasources
1. Add new module instantiation in `environments/dev/data/datasources.tf`:
   ```hcl
   module "new_datasource" {
     source = "../../../modules/datasource"
     
     project_id         = var.project_id
     region             = var.region
     name               = "new-source"
     developer_emails   = var.developer_emails
     data_editor_role = google_project_iam_custom_role.data_datasources_editor.name
   }
   ```

2. Developers automatically get access to the new bucket

### Adding Developers
1. Add email to `developer_emails` in `terraform.tfvars`

## State Management

Terraform state is stored in GCS bucket `source-terraform-bucket` with prefix `infra/state` for:
- State backup and versioning
- Team collaboration
- State locking to prevent conflicts

## Security Notes

- Never commit `terraform.tfvars` to version control
- Developer access is scoped to bronze layer buckets only
- Custom roles follow principle of least privilege
- Each datasource manages its own IAM independently
# Environment Structure

This directory contains the Terraform configurations for different environments. Currently, only the **dev** environment is configured and active.

## Structure

```
environments/
├── dev/                 # ✅ ACTIVE - Development environment
│   ├── variables.tf     # Dev environment variables
│   ├── terraform.tfvars # Dev environment values
│   └── data/            # Data layer
├── qa/                  # ⏸️  PLACEHOLDER - Not configured yet
│   └── README.md        # Setup instructions
└── prod/                # ⏸️  PLACEHOLDER - Not configured yet
    └── README.md        # Setup instructions
```


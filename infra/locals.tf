# Local configuration values
# This file contains non-sensitive configuration that can be safely committed to git

locals {
  # Change this to your own project ID if you don't have access to the original project
  project_id = "datamanagemenplatformdev"
  # project_id = "your-own-project-id"  # Uncomment and replace with your project ID
  
  developer_emails = [
    "aol@vossmoos.de"
  ]
  
  environment = "dev"
  region = "europe-west3"
} 
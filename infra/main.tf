# Main Terraform configuration
# This infrastructure uses environment-based structure
# Currently configured for dev environment

# Data Layer - Raw Data Ingestion (Dev Environment)
module "dev_environment" {
  source = "./environments/dev/data"
  
  project_id        = local.project_id
  region            = local.region
  developer_emails  = local.developer_emails
}

# Composer service account - commented out to avoid conflicts with existing service account
# resource "google_service_account" "composer-worker-sa" {
#   project = local.project_id
#   account_id   = "composer-worker"
# }

# resource "google_project_iam_member" "composer-worker" {
#   project = local.project_id
#   role    = "roles/composer.worker"
#   member  = "serviceAccount:${google_service_account.composer-worker-sa.email}"
# }

# Composer
#resource "google_composer_environment" "dev" {
#  project = local.project_id
#  name   = "dev"
#  region = local.region
# config {
#    software_config {
#      image_version = "composer-3-airflow-2.10.5-build.9"
#      # airflow_config_overrides = 
#      # pypi_packages
#      # env_variables
#      cloud_data_lineage_integration {
#        enabled = true
#      }
#    }
#    environment_size = "ENVIRONMENT_SIZE_SMALL"
#
#    node_config {
#      service_account = google_service_account.composer-worker-sa.email
#    }
#  }
#}
 

# Data Layer - Raw Data Ingestion
# This layer handles raw data ingestion from various sources

# First datasource - Midocean data ingestion
module "midocean_datasource" {
  source = "../../../modules/datasource"
  
  project_id         = var.project_id
  region             = var.region
  name               = "midocean"
  developer_emails   = var.developer_emails
  data_editor_role = google_project_iam_custom_role.data_datasources_editor.name
}

# Second datasource - Test data ingestion
# module "test_datasource" {
#   source = "../../../modules/datasource"
  
#   project_id         = var.project_id
#   region             = var.region
#   name               = "test"
#   developer_emails   = var.developer_emails
#   data_editor_role = google_project_iam_custom_role.data_datasources_editor.name
# } 
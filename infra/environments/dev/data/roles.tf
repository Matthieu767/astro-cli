# Data Layer - Custom IAM Roles
# This file defines custom roles for data layer access

# Custom role for data datasources editor
resource "google_project_iam_custom_role" "data_datasources_editor" {
  project     = var.project_id
  role_id     = "dataDatasourcesEditor"
  title       = "Data Datasources Editor"
  description = "Allows editing data in data layer datasource buckets"
  
  permissions = [
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.update",
    "storage.objects.delete",
    "storage.buckets.get"
  ]
} 
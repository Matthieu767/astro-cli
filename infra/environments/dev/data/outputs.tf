# Outputs for Data Layer

output "data_datasources_editor_role" {
  description = "Name of the data datasources editor custom role"
  value       = google_project_iam_custom_role.data_datasources_editor.name
} 
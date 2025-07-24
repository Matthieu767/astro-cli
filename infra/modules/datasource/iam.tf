# IAM for Datasource Module
# This file manages developer access to the datasource bucket

# Grant data datasources editor role to developers for this bucket
resource "google_storage_bucket_iam_member" "developer_access" {
  for_each = toset(var.developer_emails)
  
  bucket = google_storage_bucket.datasource.name
  role   = var.data_editor_role
  member = "user:${each.value}"
} 
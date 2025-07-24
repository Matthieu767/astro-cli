# Outputs for Datasource Module

output "bucket_name" {
  description = "Name of the created storage bucket"
  value       = google_storage_bucket.datasource.name
}

output "dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = google_bigquery_dataset.default.dataset_id
}

# Branding external tables
output "branding_item_table_id" {
  description = "ID of the Branding-ItemOF_Midocean external table"
  value       = google_bigquery_table.branding_item.table_id
}

output "branding_position_table_id" {
  description = "ID of the Branding-PositionOF_Midocean external table"
  value       = google_bigquery_table.branding_position.table_id
}

# Products external tables
output "products_itemlist_table_id" {
  description = "ID of the ItemlistOF_Midocean external table"
  value       = google_bigquery_table.products_itemlist.table_id
}

output "products_translation_table_id" {
  description = "ID of the Translation_Itemlist_Midocean external table"
  value       = google_bigquery_table.products_translation.table_id
}

# Services external tables
output "services_handling_group_table_id" {
  description = "ID of the HandlingGroupOF_Midocean external table"
  value       = google_bigquery_table.services_handling_group.table_id
}

output "services_pre_cost_table_id" {
  description = "ID of the PreCostOF_Midocean external table"
  value       = google_bigquery_table.services_pre_cost.table_id
}

# Full table IDs for easy reference
output "branding_item_table_full_id" {
  description = "Full ID of the Branding-ItemOF_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.branding_item.table_id}"
}

output "branding_position_table_full_id" {
  description = "Full ID of the Branding-PositionOF_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.branding_position.table_id}"
}

output "products_itemlist_table_full_id" {
  description = "Full ID of the ItemlistOF_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.products_itemlist.table_id}"
}

output "products_translation_table_full_id" {
  description = "Full ID of the Translation_Itemlist_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.products_translation.table_id}"
}

output "services_handling_group_table_full_id" {
  description = "Full ID of the HandlingGroupOF_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.services_handling_group.table_id}"
}

output "services_pre_cost_table_full_id" {
  description = "Full ID of the PreCostOF_Midocean external table"
  value       = "${var.project_id}.${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.services_pre_cost.table_id}"
}
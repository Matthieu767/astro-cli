# Variables for Bronze Layer

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "developer_emails" {
  description = "List of developer email addresses who can edit data in bronze layer buckets"
  type        = list(string)
  default     = []
} 
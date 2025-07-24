# Variables for the data flow infrastructure

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "datamanagemenplatformdev"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west3"
}

variable "developer_emails" {
  description = "List of developer email addresses who can edit data in bronze layer buckets"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  default     = "dev"
} 
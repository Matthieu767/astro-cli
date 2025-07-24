# Variables for the dev environment

variable "project_id" {
  description = "The GCP project ID for dev environment"
  type        = string
}

variable "region" {
  description = "The GCP region for dev environment"
  type        = string
  default     = "europe-west3"
}

variable "developer_emails" {
  description = "List of developer email addresses who can edit data in dev environment"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
} 
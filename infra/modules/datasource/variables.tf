# Variables for Datasource Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the datasource"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "developer_emails" {
  description = "List of developer email addresses who can edit data in this datasource bucket"
  type        = list(string)
  default     = []
}

variable "data_editor_role" {
  description = "The data datasources editor role name to grant to developers"
  type        = string
} 
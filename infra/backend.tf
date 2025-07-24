terraform {
  backend "gcs" {
    bucket = "datamanagemenplatformdev-terraform-bucket"
    prefix = "infra/state"
  }
} 
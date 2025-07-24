# Cloud Storage bucket for the datasource
resource "google_storage_bucket" "datasource" {
  name          = "${var.project_id}-${var.name}"
  location      = "EU"
  project       = var.project_id
  force_destroy = true

  labels = {
    datasource = var.name
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

} 

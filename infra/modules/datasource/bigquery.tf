
resource "google_bigquery_dataset" "default" {
  dataset_id                  = "external_${var.name}"
  location                    = "EU"

  labels = {
    datasource = var.name
  }
}

# BigQuery external table for Branding-ItemOF_Midocean
resource "google_bigquery_table" "branding_item" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "branding_itemof"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Branding/Branding-ItemOF_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "branding"
  }
}

# BigQuery external table for Branding-PositionOF_Midocean
resource "google_bigquery_table" "branding_position" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "branding_positionof"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Branding/Branding-PositionOF_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "branding"
  }
}

# BigQuery external table for ItemlistOF
resource "google_bigquery_table" "products_itemlist" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "products_itemlistof_${var.name}"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Products/ItemlistOF_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "products"
  }
}

# BigQuery external table for Translation_Itemlist_Midocean
resource "google_bigquery_table" "products_translation" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "products_translation_itemlist"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Products/Translation_Itemlist_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "products"
  }
}

# BigQuery external table for HandlingGroupOF_Midocean
resource "google_bigquery_table" "services_handling_group" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "services_handlinggroupof"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Services/HandlingGroupOF_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "services"
  }
}

# BigQuery external table for PreCostOF_Midocean
resource "google_bigquery_table" "services_pre_cost" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "services_precostof"
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    
    source_uris = [
      "gs://${google_storage_bucket.datasource.name}/Services/PreCostOF_${var.name}.csv"
    ]

    csv_options {
      encoding                 = "UTF-8"
      field_delimiter          = ";"
      skip_leading_rows        = 0
      quote                    = "\""
      allow_quoted_newlines    = true
      allow_jagged_rows        = true
    }
  }

  labels = {
    datasource = var.name
    type       = "external"
    category   = "services"
  }
}
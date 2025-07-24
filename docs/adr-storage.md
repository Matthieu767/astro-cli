# Architecture Decision Record: Storage Format and Location

## Status
Accepted

## Context
We need a scalable, cost-effective, and analytics-friendly way to store raw and processed data for our data platform. The solution must support schema evolution, easy ingestion, and efficient querying, especially with Google BigQuery.

## Decision
- **All data will be uploaded to Google Cloud Storage (GCS).**
- **Hive-style partitioning** will be used, with folders named `loaded_on=<YYYY-MM-DD>` to organize data by load date.
- **File format:** Newline-delimited JSON (NDJSON).
- **Each JSON object will have two fields:**
  - `timestamp`: The event or record timestamp (ISO 8601 format recommended)
  - `data`: The payload, which can be any JSON object (schema-less)
- **Rationale:**
  - Schema-less design allows for flexible ingestion and easy schema evolution.
  - NDJSON is natively supported by BigQuery and many other tools.
  - Hive partitioning enables efficient partition pruning in BigQuery external tables.

## Example Layout
```
gcs://<supplier-bucket>/<table>/loaded_on=2025-07-13/<table>.json
gcs://<supplier-bucket>/<table>/loaded_on=2025-07-14/<table>.json
```

## Example File Content
```json
{"timestamp": "2025-07-13T12:00:00Z", "data": {"user_id": 123, "event": "login"}}
{"timestamp": "2025-07-13T12:01:00Z", "data": {"user_id": 456, "event": "logout"}}
```

## References
- [BigQuery External Tables and Hive Partitioning](https://cloud.google.com/bigquery/docs/hive-partitioned-queries-gcs)
- [BigQuery NDJSON Support](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-json)
- [Schema Evolution in BigQuery](https://cloud.google.com/bigquery/docs/schemas#evolving)

## Consequences
- Data is easily queryable in BigQuery using external tables.
- Schema changes do not require reprocessing old data.
- Partitioning by load date simplifies data lifecycle management and cost control.

---

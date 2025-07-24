#!/bin/bash
# Upload Airflow project files to Google Composer GCS bucket
# Usage: ./upload_to_composer.sh gs://your-composer-bucket

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <GCS_BUCKET>"
  exit 1
fi

GCS_BUCKET=$1
LOCAL_AIRFLOW_DIR=$(dirname "$0")

# Sync DAGs
gsutil -m rsync -r "$LOCAL_AIRFLOW_DIR/dags" "$GCS_BUCKET/dags"

# Sync plugins (if any)
gsutil -m rsync -r "$LOCAL_AIRFLOW_DIR/plugins" "$GCS_BUCKET/plugins"

# Sync data (if any)
gsutil -m rsync -r "$LOCAL_AIRFLOW_DIR/data" "$GCS_BUCKET/data"

# Upload requirements.txt (if present)
if [ -f "$LOCAL_AIRFLOW_DIR/requirements.txt" ]; then
  gsutil cp "$LOCAL_AIRFLOW_DIR/requirements.txt" "$GCS_BUCKET/"
fi

echo "Upload to Composer bucket $GCS_BUCKET complete."

# Airflow Project

This directory contains DAGs, plugins, and data for local Airflow development and Google Composer deployment.

# Local Development install 
install uv
```bash
pip install uv
uv sync
. .venv/bin/activate
```

# Verify airflow standalone is working
```bash
gcloud auth application-default login
./start-airflow-standalone.sh
```

# login to Airlfow UI
Open your browser and navigate to `http://localhost:8080` to access the Airflow UI.

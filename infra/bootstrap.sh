gcloud config set project datamanagemenplatformdev

gcloud services enable iamcredentials.googleapis.com iam.googleapis.com

gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
  --attribute-condition="attribute.repository=='source-promo/data_management_platform'"

gcloud iam service-accounts create github-deployer \
  --display-name="GitHub Actions Deployer"

gcloud iam service-accounts list --filter="displayName:GitHub Actions Deployer"

# it gives: GitHub Actions Deployer  github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com
# get project number for the next command: gcloud projects describe datamanagemenplatformdev --format="value(projectNumber)"
gcloud iam service-accounts add-iam-policy-binding github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/703716690424/locations/global/workloadIdentityPools/github-pool/attribute.repository/source-promo/data_management_platform"

gcloud storage buckets create gs://datamanagemenplatformdev-terraform-bucket \
  --location=europe-west3 \
  --uniform-bucket-level-access

# Grant storage admin permissions to the GitHub deployer service account for all buckets
gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Grant additional permissions for Terraform operations
gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"

# Grant dataform admin role
gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/dataform.admin"

# Grant bigquery admin role
gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding datamanagemenplatformdev \
  --member="serviceAccount:github-deployer@datamanagemenplatformdev.iam.gserviceaccount.com" \
  --role="roles/iam.roleAdmin"
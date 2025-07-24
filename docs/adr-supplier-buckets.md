# Architecture Decision Record: Supplier Storage Buckets

## Status
Accepted

## Context
Our platform ingests data from multiple suppliers. Each supplier may have different data access requirements, and we must ensure data isolation, security, and ease of permission management. Sharing a single bucket across suppliers could lead to complex permission structures and potential data leakage.

## Decision
- **Each supplier will be assigned a dedicated Google Cloud Storage (GCS) bucket.**
- Data from each supplier will be uploaded only to their respective bucket.
- Permissions will be managed at the bucket level, ensuring that suppliers cannot access each other's data.

## Rationale
- Simplifies permission management by isolating access at the bucket level.
- Reduces risk of accidental or malicious data access between suppliers.
- Makes it easier to audit, monitor, and manage data for each supplier independently.
- Aligns with best practices for multi-tenant data platforms.

## Example Layout
```
gcs://supplier-abc-bucket/
gcs://supplier-xyz-bucket/
```

## References
- [Google Cloud Storage IAM Permissions](https://cloud.google.com/storage/docs/access-control/iam)
- [Best Practices for Using Cloud Storage](https://cloud.google.com/storage/docs/best-practices)

## Consequences
- Each supplier's data is fully isolated.
- Onboarding a new supplier involves creating a new bucket and assigning permissions.
- Slightly more buckets to manage, but with much simpler and safer access control.

---

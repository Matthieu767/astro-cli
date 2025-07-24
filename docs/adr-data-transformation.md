# Architecture Decision Record: Data Transformation Approach

## Status
Accepted

## Context
Our platform requires robust, scalable, and maintainable data transformation processes. The transformations must integrate well with Google BigQuery, support analytics workloads, and be easy to manage and audit.

## Decision
- **Dataform with SQL is the primary tool for data transformation.**
- **Python** may be used as a fallback for complex transformations not easily expressed in SQL.
- **All data transformation should remain within BigQuery as much as possible.**

## Rationale
- SQL is declarative, widely understood, and well-suited for set-based analytics and transformations.
- Dataform provides modularity, dependency management, and testing for SQL-based pipelines.
- Keeping transformations in BigQuery:
  - Leverages BigQuery's scalability and performance.
  - Minimizes data movement, reducing cost and complexity.
  - Simplifies security and compliance by keeping data in one place.
  - Enables use of BigQuery's advanced features (partitioning, clustering, UDFs, etc.).
- Python is only used when SQL is insufficient, ensuring most logic is transparent and maintainable.
- This approach aligns with modern data engineering best practices for cloud-native analytics.

## Example Workflow
1. **Write Dataform SQL models** for all standard transformations.
2. **Use Python (in Dataform or via BigQuery UDFs)** only for advanced or non-SQL logic.
3. **Avoid exporting data for transformation outside BigQuery** unless absolutely necessary.

## References
- [Dataform Documentation](https://docs.dataform.co/)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [Best Practices for Dataform and BigQuery](https://docs.dataform.co/guides/bigquery)

## Consequences
- Transformations are scalable, maintainable, and auditable.
- Most logic is in SQL, making it accessible to analysts and engineers.
- Data stays in BigQuery, reducing risk and operational overhead.
- Some complex cases may require Python, but these are minimized and documented.

---

# Architecture Decision Record: GitHub Monorepo Structure

## Status
Accepted

## Context
Our platform consists of multiple components (e.g., Airflow, Dataform, Infra, documentation) that are closely related and often need to be developed, tested, and deployed together. Managing these in separate repositories can lead to coordination overhead, versioning issues, and duplicated effort.

## Decision
- **We will use a single GitHub monorepo to manage all components of the data platform.**
- Each major component will have its own top-level directory (e.g., `airflow/`, `dataform/`, `infra/`, `docs/`).

## Rationale
- Simplifies dependency management and cross-component changes.
- Easier to coordinate releases and ensure compatibility between components.
- Centralizes documentation, issues, and CI/CD workflows.
- Reduces duplicated configuration and boilerplate.
- Enables atomic commits and rollbacks across the entire platform.
- Aligns with best practices for modern data and platform engineering teams.

## Example Layout
```
/airflow
/dataform
/infra
/docs
```

## References
- [Monorepo vs Polyrepo: How to Choose](https://martinfowler.com/articles/monorepos.html)
- [Google: Why We Use a Monorepo](https://opensource.googleblog.com/2015/09/why-google-stores-build-tools-in.html)

## Consequences
- All code, configuration, and documentation are in one place.
- Onboarding and collaboration are simplified.
- Some tooling or CI/CD configuration may need to be adapted for monorepo workflows.

---

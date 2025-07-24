# Architecture Decision Record: Infrastructure as Code (IaC)

## Status
Accepted

## Context
Managing cloud infrastructure manually is error-prone, hard to audit, and difficult to reproduce. To ensure consistency, repeatability, and security, we need a clear approach for provisioning and managing infrastructure resources.

## Decision
- **Infrastructure as Code (IaC) is the default approach for all infrastructure provisioning and management.**
- **Terraform** is the technology of choice for IaC.
- If a resource cannot be provisioned via Terraform, we will use a bootstrap script or automation as a fallback.
- As a last resort, manual setup via the cloud provider UI is allowed, but must be documented and tracked for future automation.

## Rationale
- IaC enables version control, peer review, and automated deployment of infrastructure.
- Terraform is widely adopted, cloud-agnostic, and supports modular, reusable code.
- Fallbacks ensure progress is not blocked by IaC limitations, but manual steps are minimized and tracked.

## Example Workflow
1. **Write Terraform code** for all possible resources.
2. **Use bootstrap scripts** (e.g., shell, Python) for resources not supported by Terraform.
3. **Manual UI setup** only if absolutely necessary, with documentation for future automation.

## References
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [Infrastructure as Code Best Practices](https://learn.hashicorp.com/collections/terraform/best-practices)

## Consequences
- Infrastructure is reproducible, auditable, and consistent across environments.
- Most changes are peer-reviewed and tracked in version control.
- Some manual steps may remain, but are minimized and documented for future automation.

---

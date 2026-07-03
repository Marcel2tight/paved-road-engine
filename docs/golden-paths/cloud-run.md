# Cloud Run Golden Path

## Purpose

The Cloud Run Golden Path provides a standardized, secure, and fully governed deployment pattern for stateless workloads on the Paved Road Platform.

---

## When to Use

Cloud Run is the preferred platform for:

- REST APIs
- Microservices
- Event-driven services
- Web applications
- Background workers
- Stateless workloads

---

## When NOT to Use

Cloud Run is not recommended for:

- Stateful applications
- Long-running batch jobs
- Applications requiring persistent local storage
- Workloads requiring privileged containers
- Highly specialized networking requirements

---

## Platform Features

Applications deployed through this Golden Path automatically inherit:

- Secure platform defaults
- Workload Identity Federation (OIDC)
- Infrastructure as Code (Terraform)
- Policy as Code (OPA)
- CI/CD automation (GitHub Actions)
- Security and policy gates
- Cloud Logging integration
- Cloud Monitoring integration
- SLO-based observability
- FinOps governance
- Mandatory resource labeling
- Software supply chain security
- Container vulnerability scanning
- SBOM generation
- Keyless image signing using Cosign

---

## Provisioning Workflow

Developers provision Cloud Run services through Backstage.

### Steps

1. Open the Backstage Portal.
2. Select **Create**.
3. Choose the **Cloud Run Template**.
4. Provide required parameters.
5. Submit the template.
6. Review the generated Pull Request.
7. Merge after validation succeeds.

---

## Required Parameters

Typical inputs include:

| Parameter | Description |
|-----------|-------------|
| service_name | Cloud Run service name |
| region | Deployment region |
| image | Container image |
| environment | dev, stage, prod |
| service_account_email | Runtime identity |

---

## Deployment Flow

```text
Developer
    ↓
Backstage Portal
    ↓
Scaffolder Template
    ↓
GitHub Pull Request
    ↓
OPA Policy Validation
    ↓
Terraform Validation
    ↓
Security Gates (Checkov/tfsec)
    ↓
Terraform Deployment
    ↓
Artifact Registry
    ↓
Cloud Run
    ↓
Monitoring & SLOs
```

---

## Operational Standards

Every Cloud Run workload must:

- Use approved templates
- Pass policy validation
- Include mandatory labels
- Use approved container repositories
- Use signed container images
- Meet platform security standards

---

## Observability Standards

Every service receives:

- Cloud Logging
- Cloud Monitoring
- SLO definitions
- Burn-rate alerting
- Slack notifications
- Email notifications

---

## Cost Governance Standards

Every workload must include:

```text
environment
managed_by
platform
owner
cost_center
```

labels to support chargeback and FinOps.

---

## Ownership

| Attribute | Value |
|-----------|-------|
| Platform Owner | platform-team |
| Lifecycle | production |
| Cloud Provider | Google Cloud |
| Runtime | Cloud Run |
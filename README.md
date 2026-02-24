# aicp-infra

Terraform infrastructure for the AICP platform on Google Cloud.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Authenticated GCP session: `gcloud auth application-default login`

## Setup

```bash
terraform init
terraform plan
terraform apply
```

## Project Structure

```
.
├── CLAUDE.md       # AI assistant instructions
├── README.md       # This file
├── versions.tf     # Terraform + provider version constraints
├── providers.tf    # Google provider configuration
├── variables.tf    # Input variables
├── main.tf         # Infrastructure resources
└── outputs.tf      # Output values
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `project_id` | `aicp-dev` | GCP project ID |
| `region` | `us-central1` | GCP region |

Override defaults:

```bash
terraform apply -var="region=us-east1"
```

Or create a `terraform.tfvars`:

```hcl
project_id = "aicp-dev"
region     = "us-central1"
```

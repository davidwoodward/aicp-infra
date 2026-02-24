## Project: aicp-infra

Terraform infrastructure for the AICP platform on Google Cloud.

## GCP Project

- **Project ID**: `aicp-dev`
- **Default Region**: `us-central1`

## Project Structure

Flat Terraform layout — no modules. All resources live in the root.

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider version constraints |
| `providers.tf` | Google provider configuration |
| `variables.tf` | Input variables |
| `main.tf` | Infrastructure resources |
| `outputs.tf` | Output values |

## Conventions

- **No modules** — keep everything flat until complexity demands it
- **No over-abstraction** — add resources directly to `main.tf`
- Resources should use `var.project_id` and `var.region` — never hardcode
- Use standard Terraform naming: `snake_case` for resources and variables
- Group related resources with comment headers in `main.tf`

## Terraform Commands

```bash
terraform init          # Initialize providers
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Tear down infrastructure
terraform fmt -recursive # Format all .tf files
terraform validate      # Validate configuration
```

## State

State backend is not yet configured (local by default). When adding remote state, configure it in `versions.tf` inside the `terraform` block.

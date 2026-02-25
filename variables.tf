variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "aicp-dev"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "backend_image" {
  description = "Container image for the AICP backend Cloud Run service"
  type        = string
  default     = "us-central1-docker.pkg.dev/aicp-dev/aicp/aicp:latest"
}

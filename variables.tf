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

variable "google_oauth_client_id" {
  description = "Google OAuth 2.0 Client ID for authentication"
  type        = string
  default     = "211027517197-4osoj7u1jq2gqs1jsaiu1b0u2ab7a5qs.apps.googleusercontent.com"
}

variable "default_llm_provider" {
  description = "Default LLM provider (gemini, openai, or anthropic)"
  type        = string
  default     = "gemini"
}

variable "github_oauth_client_id" {
  description = "GitHub OAuth App Client ID for authentication"
  type        = string
  default     = "Ov23liS2EbcTCZ36bwUb"
}

variable "github_app_id" {
  description = "GitHub App ID for issue integration"
  type        = string
  default     = "2991797"
}

variable "github_app_slug" {
  description = "GitHub App URL slug for frontend install link"
  type        = string
  default     = "aicp-github-app"
}

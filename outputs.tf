# Output values go here

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "backend_service_account_email" {
  description = "The email of the AICP backend service account"
  value       = google_service_account.backend.email
}

output "cloud_run_url" {
  description = "The URL of the AICP backend Cloud Run service"
  value       = google_cloud_run_v2_service.backend.uri
}

output "firestore_database_name" {
  description = "The name of the Firestore database"
  value       = google_firestore_database.default.name
}

output "artifact_registry_url" {
  description = "The Artifact Registry URL for container images"
  value       = local.registry_url
}

output "cloudbuild_service_account_email" {
  description = "The email of the Cloud Build service account"
  value       = google_service_account.cloudbuild.email
}

output "cloudbuild_trigger_id" {
  description = "The ID of the Cloud Build trigger for backend deploys"
  value       = google_cloudbuild_trigger.backend_deploy.trigger_id
}

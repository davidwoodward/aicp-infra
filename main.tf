# -----------------------------------------------
# APIs
# -----------------------------------------------

resource "google_project_service" "firestore" {
  project = var.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

# -----------------------------------------------
# Locals
# -----------------------------------------------

locals {
  registry_url = "${var.region}-docker.pkg.dev/${var.project_id}/aicp"
}

# -----------------------------------------------
# Artifact Registry
# -----------------------------------------------

resource "google_artifact_registry_repository" "aicp" {
  project       = var.project_id
  location      = var.region
  repository_id = "aicp"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# -----------------------------------------------
# Firestore
# -----------------------------------------------

resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore]
}

# -----------------------------------------------
# Service Accounts
# -----------------------------------------------

resource "google_service_account" "backend" {
  project      = var.project_id
  account_id   = "aicp-backend-sa"
  display_name = "AICP Backend Service Account"

  depends_on = [google_project_service.iam]
}

# -----------------------------------------------
# IAM
# -----------------------------------------------

resource "google_project_iam_member" "backend_datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_project_iam_member" "backend_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# -----------------------------------------------
# Cloud Run
# -----------------------------------------------

resource "google_cloud_run_v2_service" "backend" {
  project  = var.project_id
  name     = "aicp-backend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.backend.email

    scaling {
      min_instance_count = 1
    }

    timeout = "3600s"

    containers {
      image = var.backend_image

      ports {
        container_port = 8080
      }

      env {
        name  = "FIRESTORE_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    max_instance_request_concurrency = 10
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [
    google_project_service.run,
    google_service_account.backend,
    google_artifact_registry_repository.aicp,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  project  = var.project_id
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

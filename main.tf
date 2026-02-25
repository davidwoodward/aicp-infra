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

resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
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
# Firestore Indexes
# -----------------------------------------------

resource "google_firestore_index" "prompts_project_order" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "prompts"

  fields {
    field_path = "project_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "order_index"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "sessions_project_started" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "sessions"

  fields {
    field_path = "project_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "started_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "sessions_agent_started" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "sessions"

  fields {
    field_path = "agent_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "started_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "messages_session_timestamp" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "messages"

  fields {
    field_path = "session_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "timestamp"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.default]
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

resource "google_service_account" "cloudbuild" {
  project      = var.project_id
  account_id   = "aicp-cloudbuild-sa"
  display_name = "AICP Cloud Build Service Account"

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

resource "google_project_iam_member" "cloudbuild_artifactregistry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "cloudbuild_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "cloudbuild_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# -----------------------------------------------
# Secrets (LLM API Keys)
# -----------------------------------------------

resource "google_secret_manager_secret" "gemini_api_key" {
  project   = var.project_id
  secret_id = "gemini-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret" "openai_api_key" {
  project   = var.project_id
  secret_id = "openai-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret" "anthropic_api_key" {
  project   = var.project_id
  secret_id = "anthropic-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "backend_gemini" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_secret_manager_secret_iam_member" "backend_openai" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.openai_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_secret_manager_secret_iam_member" "backend_anthropic" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.anthropic_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

# Cloud Run service agent needs secret access to inject env vars
locals {
  cloud_run_agent = "service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_secret_manager_secret_iam_member" "run_agent_gemini" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.gemini_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

resource "google_secret_manager_secret_iam_member" "run_agent_openai" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.openai_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

resource "google_secret_manager_secret_iam_member" "run_agent_anthropic" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.anthropic_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

# -----------------------------------------------
# Cloud Run
# -----------------------------------------------

resource "google_cloud_run_v2_service" "backend" {
  project             = var.project_id
  name                = "aicp"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

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

      env {
        name  = "DEFAULT_LLM_PROVIDER"
        value = var.default_llm_provider
      }

      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.gemini_api_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "OPENAI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.openai_api_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "ANTHROPIC_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.anthropic_api_key.secret_id
            version = "latest"
          }
        }
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
    google_secret_manager_secret_iam_member.backend_gemini,
    google_secret_manager_secret_iam_member.backend_openai,
    google_secret_manager_secret_iam_member.backend_anthropic,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  project  = var.project_id
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# -----------------------------------------------
# Cloud Build
# -----------------------------------------------

resource "google_cloudbuild_trigger" "backend_deploy" {
  project  = var.project_id
  name     = "aicp-deploy"
  location = var.region

  github {
    owner = "davidwoodward"
    name  = "aicp-app"

    push {
      branch = "^main$"
    }
  }

  filename        = "cloudbuild.yaml"
  service_account = google_service_account.cloudbuild.id

  substitutions = {
    _REGION     = var.region
    _REPOSITORY = "${var.region}-docker.pkg.dev/${var.project_id}/aicp"
    _SERVICE    = "aicp"
    _IMAGE      = "aicp"
  }

  depends_on = [
    google_project_service.cloudbuild,
    google_service_account.cloudbuild,
  ]
}

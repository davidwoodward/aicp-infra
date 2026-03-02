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

resource "google_firestore_index" "chat_messages_conversation_timestamp" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "chat_messages"

  fields {
    field_path = "conversation_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "timestamp"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippets_collection_updated" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippets"

  fields {
    field_path = "collection_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippets_active_by_updated" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippets"

  fields {
    field_path = "deleted_at"
    order      = "ASCENDING"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippet_collections_active_by_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippet_collections"

  fields {
    field_path = "deleted_at"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "activity_logs_entity_type_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "activity_logs"

  fields {
    field_path = "entity_type"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "activity_logs_project_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "activity_logs"

  fields {
    field_path = "project_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "activity_logs_entity_id_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "activity_logs"

  fields {
    field_path = "entity_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

# Project-level history: WHERE user_id == X AND entity_type == Y AND project_id == Z ORDER BY created_at DESC
resource "google_firestore_index" "activity_logs_user_type_project_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "activity_logs"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "entity_type"
    order      = "ASCENDING"
  }

  fields {
    field_path = "project_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

# Prompt-level history: WHERE user_id == X AND entity_type == Y AND project_id == Z AND entity_id == W ORDER BY created_at DESC
resource "google_firestore_index" "activity_logs_user_type_project_entity_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "activity_logs"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "entity_type"
    order      = "ASCENDING"
  }

  fields {
    field_path = "project_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "entity_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

# -----------------------------------------------
# Firestore Indexes (user_id scoped)
# -----------------------------------------------

resource "google_firestore_index" "projects_user_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "projects"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "conversations_user_updated" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "conversations"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "prompts_user_order" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "prompts"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "order_index"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippets_user_active_updated" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippets"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "deleted_at"
    order      = "ASCENDING"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippets_user_deleted" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippets"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "deleted_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippet_collections_user_active_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippet_collections"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "deleted_at"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "snippet_collections_user_deleted" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "snippet_collections"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "deleted_at"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "github_installations_user_created" {
  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = "github_installations"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "created_at"
    order      = "DESCENDING"
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
# Secrets (Application Encryption Key)
# -----------------------------------------------

resource "random_password" "llm_encryption_key" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "llm_encryption_key" {
  project   = var.project_id
  secret_id = "llm-encryption-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "llm_encryption_key" {
  secret      = google_secret_manager_secret.llm_encryption_key.id
  secret_data = random_password.llm_encryption_key.result
}

resource "google_secret_manager_secret_iam_member" "backend_encryption_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.llm_encryption_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

# -----------------------------------------------
# Secrets (GitHub OAuth Client Secret)
# -----------------------------------------------

resource "google_secret_manager_secret" "github_oauth_client_secret" {
  project   = var.project_id
  secret_id = "github-oauth-client-secret"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "backend_github_oauth_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_oauth_client_secret.secret_id
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

resource "google_secret_manager_secret_iam_member" "run_agent_encryption_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.llm_encryption_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

resource "google_secret_manager_secret_iam_member" "run_agent_github_oauth_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_oauth_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

# -----------------------------------------------
# Secrets (GitHub App Private Key)
# -----------------------------------------------

resource "google_secret_manager_secret" "github_app_private_key" {
  project   = var.project_id
  secret_id = "github-app-private-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "backend_github_app_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_app_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_secret_manager_secret_iam_member" "run_agent_github_app_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_app_private_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloud_run_agent}"
}

# -----------------------------------------------
# Secrets (GitHub Webhook Secret)
# -----------------------------------------------

resource "google_secret_manager_secret" "github_webhook_secret" {
  project   = var.project_id
  secret_id = "github-webhook-secret"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "backend_github_webhook_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_webhook_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_secret_manager_secret_iam_member" "run_agent_github_webhook_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_webhook_secret.secret_id
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
      max_instance_count = 3
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
        name  = "GOOGLE_OAUTH_CLIENT_ID"
        value = var.google_oauth_client_id
      }

      env {
        name = "LLM_ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.llm_encryption_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GITHUB_OAUTH_CLIENT_ID"
        value = var.github_oauth_client_id
      }

      env {
        name = "GITHUB_OAUTH_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.github_oauth_client_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GITHUB_APP_ID"
        value = var.github_app_id
      }

      env {
        name = "GITHUB_APP_PRIVATE_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.github_app_private_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GITHUB_WEBHOOK_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.github_webhook_secret.secret_id
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
    google_secret_manager_secret_iam_member.backend_encryption_key,
    google_secret_manager_secret_iam_member.backend_github_oauth_secret,
    google_secret_manager_secret_iam_member.backend_github_app_key,
    google_secret_manager_secret_iam_member.backend_github_webhook_secret,
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
# Domain Mapping
# -----------------------------------------------

resource "google_cloud_run_domain_mapping" "aicp" {
  project  = var.project_id
  name     = "aicp.dbwoodward.com"
  location = var.region

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.backend.name
  }

  depends_on = [google_cloud_run_v2_service.backend]
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
    _REGION                  = var.region
    _REPOSITORY              = "${var.region}-docker.pkg.dev/${var.project_id}/aicp"
    _SERVICE                 = "aicp"
    _IMAGE                   = "aicp"
    _GOOGLE_OAUTH_CLIENT_ID  = var.google_oauth_client_id
    _GITHUB_OAUTH_CLIENT_ID  = var.github_oauth_client_id
    _GITHUB_APP_SLUG         = var.github_app_slug
  }

  depends_on = [
    google_project_service.cloudbuild,
    google_service_account.cloudbuild,
  ]
}

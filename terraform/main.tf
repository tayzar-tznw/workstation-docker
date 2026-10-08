locals {
  cluster_id = var.create_cluster ? google_workstations_workstation_cluster.this[0].workstation_cluster_id : var.cluster_id
  repository = var.create_artifact_registry_repository ? google_artifact_registry_repository.images[0].repository_id : var.artifact_registry_repository
  image      = "${var.region}-docker.pkg.dev/${var.project_id}/${local.repository}/${var.image_name}:${var.image_tag}"
}

resource "google_project_service" "services" {
  for_each = toset([
    "workstations.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    # Antigravity signs in through Agent Platform with the user's credentials.
    "aiplatform.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "images" {
  count = var.create_artifact_registry_repository ? 1 : 0

  location      = var.region
  repository_id = var.artifact_registry_repository
  format        = "DOCKER"
  description   = "Cloud Workstations images"

  depends_on = [google_project_service.services]
}

# Workstation VMs only need to pull the image and write logs and metrics; users
# act with their own credentials pushed to the workstation.
resource "google_service_account" "workstations" {
  account_id   = "workstations-vm"
  display_name = "Cloud Workstations VMs"
}

resource "google_artifact_registry_repository_iam_member" "workstations" {
  location   = var.region
  repository = local.repository
  role       = "roles/artifactregistry.reader"
  member     = google_service_account.workstations.member
}

resource "google_project_iam_member" "workstations" {
  for_each = toset(["roles/logging.logWriter", "roles/monitoring.metricWriter"])

  project = var.project_id
  role    = each.value
  member  = google_service_account.workstations.member
}

resource "google_workstations_workstation_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  workstation_cluster_id = var.cluster_id
  location               = var.region
  network                = "projects/${var.project_id}/global/networks/${var.network}"
  subnetwork             = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"

  depends_on = [google_project_service.services]
}

resource "google_workstations_workstation_config" "this" {
  workstation_config_id  = var.config_id
  workstation_cluster_id = local.cluster_id
  location               = var.region
  idle_timeout           = "${var.idle_timeout_seconds}s"
  running_timeout        = "${var.running_timeout_seconds}s"

  host {
    gce_instance {
      machine_type      = var.machine_type
      pool_size         = var.pool_size
      boot_disk_size_gb = var.boot_disk_size_gb
      service_account   = google_service_account.workstations.email
    }
  }

  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = var.home_disk_size_gb
      disk_type      = var.home_disk_type
      reclaim_policy = "DELETE"
    }
  }

  container {
    image = local.image
  }

  depends_on = [google_artifact_registry_repository_iam_member.workstations]
}

# The provider doesn't support enablePushingCredentials yet, so it is set through
# the v1beta API. Needs gcloud and curl where Terraform runs, and is not reverted
# by setting enable_pushing_credentials back to false.
resource "terraform_data" "enable_pushing_credentials" {
  count = var.enable_pushing_credentials ? 1 : 0

  triggers_replace = [google_workstations_workstation_config.this.uid]

  provisioner "local-exec" {
    command = <<-EOT
      curl --fail-with-body -sS -X PATCH \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        "https://workstations.googleapis.com/v1beta/${google_workstations_workstation_config.this.id}?updateMask=enablePushingCredentials" \
        -d '{"enablePushingCredentials": true}'
    EOT
  }
}

resource "google_workstations_workstation" "this" {
  for_each = var.workstations

  workstation_id         = each.key
  workstation_config_id  = google_workstations_workstation_config.this.workstation_config_id
  workstation_cluster_id = local.cluster_id
  location               = var.region
}

resource "google_workstations_workstation_iam_member" "users" {
  for_each = var.workstations

  workstation_id         = google_workstations_workstation.this[each.key].workstation_id
  workstation_config_id  = google_workstations_workstation_config.this.workstation_config_id
  workstation_cluster_id = local.cluster_id
  location               = var.region
  role                   = "roles/workstations.user"
  member                 = "user:${each.value}"
}

resource "google_project_iam_member" "aiplatform_users" {
  for_each = var.grant_aiplatform_user ? toset(values(var.workstations)) : toset([])

  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "user:${each.value}"
}

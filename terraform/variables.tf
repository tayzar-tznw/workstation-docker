variable "project_id" {
  description = "Project to create the workstation resources in."
  type        = string
}

variable "region" {
  description = "Region for the workstation cluster and the Artifact Registry repository."
  type        = string
  default     = "asia-northeast1"
}

# Cluster

variable "create_cluster" {
  description = "Create the workstation cluster. Set to false to use an existing cluster named cluster_id."
  type        = bool
  default     = true
}

variable "cluster_id" {
  description = "ID of the workstation cluster to create or use."
  type        = string
  default     = "workshop-cluster"
}

variable "network" {
  description = "VPC network for a new cluster."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork (in region) for a new cluster."
  type        = string
  default     = "default"
}

# Image

variable "create_artifact_registry_repository" {
  description = "Create the Artifact Registry repository. Set to false to use an existing one."
  type        = bool
  default     = true
}

variable "artifact_registry_repository" {
  description = "Artifact Registry Docker repository (in region) that holds the workstation image."
  type        = string
  default     = "workstation-images"
}

variable "image_name" {
  description = "Name of the workstation image built from the Dockerfile."
  type        = string
  default     = "workstation"
}

variable "image_tag" {
  description = "Tag of the workstation image."
  type        = string
  default     = "latest"
}

# Workstation configuration

variable "config_id" {
  description = "ID of the workstation configuration."
  type        = string
  default     = "workshop-config"
}

variable "machine_type" {
  description = "Machine type of the workstation VMs."
  type        = string
  default     = "e2-standard-8"
}

variable "pool_size" {
  description = "Number of VMs kept warm for fast starts. Warm VMs are billed while idle."
  type        = number
  default     = 0
}

variable "boot_disk_size_gb" {
  description = "Boot disk size of the workstation VMs."
  type        = number
  default     = 50
}

variable "home_disk_size_gb" {
  description = "Size of the persistent /home disk."
  type        = number
  default     = 100
}

variable "home_disk_type" {
  description = "Disk type of the persistent /home disk."
  type        = string
  default     = "pd-ssd"
}

variable "idle_timeout_seconds" {
  description = "Stop a workstation after this many seconds without activity."
  type        = number
  default     = 21600
}

variable "running_timeout_seconds" {
  description = "Stop a workstation after it has been running for this many seconds."
  type        = number
  default     = 43200
}

variable "enable_pushing_credentials" {
  description = "Let users push their Google credentials to their workstation (\"Sign in to your Workstation\"). Required by the Antigravity extension."
  type        = bool
  default     = true
}

# Workstations

variable "workstations" {
  description = "Workstations to create, as workstation ID => email of the user who gets access to it."
  type        = map(string)
  default     = {}
}

variable "grant_aiplatform_user" {
  description = "Grant workstation users roles/aiplatform.user, which Antigravity needs to sign in with their workstation credentials."
  type        = bool
  default     = true
}

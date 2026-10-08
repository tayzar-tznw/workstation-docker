output "image" {
  description = "Image the workstation configuration runs. Build it from the Dockerfile with Cloud Build."
  value       = local.image
}

output "workstation_config" {
  description = "Full name of the workstation configuration."
  value       = google_workstations_workstation_config.this.id
}

output "service_account" {
  description = "Service account of the workstation VMs."
  value       = google_service_account.workstations.email
}

output "workstation_urls" {
  description = "URL of each workstation."
  value       = { for id, workstation in google_workstations_workstation.this : id => "https://${workstation.host}" }
}

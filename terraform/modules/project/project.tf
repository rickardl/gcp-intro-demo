

resource "google_project" "project" {
 name            = var.project_name
 project_id      = var.project_id
 folder_id       = var.folder_id
 billing_account = var.billing_account
}

resource "google_project_services" "project" {
 project = google_project.project.project_id
 services = [
   "compute.googleapis.com"
 ]
}

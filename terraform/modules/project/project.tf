locals {
  my_name       = var.project_name
  my_deployment = "${var.prefix}-${var.env}"
}


resource "google_project" "infra_project" {
  name                = var.project_name
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = false
  labels = {
    name        = local.my_name
    deployment  = local.my_deployment
    prefix      = var.prefix
    environment = var.env
    region      = var.region
    zone        = var.zone
    terraform   = true
  }
}

# NOTE: compute has dependency to oslogin.
resource "google_project_services" "infra_project" {
  project = google_project.infra_project.project_id
  services = [
    "oslogin.googleapis.com",
    "compute.googleapis.com"
 ]
}

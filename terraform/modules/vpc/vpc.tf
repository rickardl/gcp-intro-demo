locals {
  my_name       = "${var.prefix}-${var.env}-vpc"
  my_deployment = "${var.prefix}-${var.env}"
}


resource "google_compute_network" "vpc" {
  name                    = local.my_name
  auto_create_subnetworks = false
  project                 = var.infra_project_id

}

resource "google_compute_subnetwork" "app-subnetwork" {
  name                     = "${local.my_name}-app-subnetwork"
  ip_cidr_range            = var.app_subnet_cidr_block
  network                  = google_compute_network.vpc.self_link
  region                   = var.region
  project                  = var.infra_project_id
}

resource "google_compute_firewall" "app-firewall" {
  name                     = "${local.my_name}-app-firewall"
  network                  = google_compute_network.vpc.self_link
  project                  = var.infra_project_id
  direction                = "INGRESS"
  priority                 = 500
  description              = "Allow SSH to app-subnetwork VM instances"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["app"]
}
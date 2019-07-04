locals {
  my_name        = "${var.prefix}-${var.env}-vm"
  my_deployment  = "${var.prefix}-${var.env}"
  my_private_key = "vm_id_rsa"
}



# NOTE: You need to "terraform init" to get the tls provider!
resource "tls_private_key" "app_vm_ssh_key" {
  algorithm   = "RSA"
}

# NOTE: If you get 'No available provider "null" plugins'
# Try: terraform init, terraform get, terraform plan.
# I.e. resource occasionally fails the first time.
# When the resource is succesfull you should see the private key
# in ./terraform/modules/vm/.ssh folder.

# We have two versions since the private ssh key needs to be stored in the local
# developer workstation differently in Linux and Windows workstations.

# First the Linux version (my_workstation_is_linux = 1)
resource "null_resource" "app_vm_save_ssh_key_linux" {
  count = "${var.my_workstation_is_linux}"
  triggers = {
    key = "${tls_private_key.app_vm_ssh_key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.app_vm_ssh_key.private_key_pem}" > ${path.module}/.ssh/${local.my_private_key}
      chmod 0600 ${path.module}/.ssh/${local.my_private_key}
EOF
  }
}


# Then the Windows version (my_workstation_is_linux = 0)
# Solution to store the file in Windows with UTF-8 encoding
# and fixing the access rights for the file kindly provided by Sami Huhtiniemi.
resource "null_resource" "app_vm_save_ssh_key_windows" {
  count = "${1 - var.my_workstation_is_linux}"
  triggers = {
    key = "${tls_private_key.app_vm_ssh_key.private_key_pem}"
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell"]
    command = <<EOF
      md ${path.module}\\.ssh
      [IO.File]::WriteAllLines(("${path.module}\.ssh\${local.my_private_key}"), "${tls_private_key.app_vm_ssh_key.private_key_pem}")
      icacls ${path.module}\.ssh\${local.my_private_key} /reset
      icacls ${path.module}\.ssh\${local.my_private_key} /grant:r "$($env:USERNAME):(R,W)"
      icacls ${path.module}\.ssh\${local.my_private_key} /inheritance:r
EOF
  }
}


resource "google_compute_address" "app-vm-external-ip" {
  name    = "${local.my_name}-external-ip"
  project = var.infra_project_id
}


resource "google_compute_instance" "app-vm" {
  name         = "${local.my_name}-app"
  project      = var.infra_project_id
  machine_type = "f1-micro"
  zone         = var.zone

  metadata = {
    ssh-keys = "${format("user:%s", tls_private_key.app_vm_ssh_key.public_key_openssh)}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = var.app_subnetwork_link
    access_config {
      nat_ip = google_compute_address.app-vm-external-ip.address
    }
  }

  labels = {
    name        = "${local.my_name}-app"
    deployment  = local.my_deployment
    prefix      = var.prefix
    environment = var.env
    region      = var.region
    zone        = var.zone
    terraform   = true
  }
}

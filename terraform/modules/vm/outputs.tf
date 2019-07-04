
output "app_vm_name" {
  value = google_compute_instance.app-vm.name
}

output "app_vm_external_ip" {
  value = "${google_compute_instance.app-vm.network_interface.0.access_config.0.nat_ip}"
}
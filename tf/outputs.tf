output "vm_ip" {
  value = yandex_compute_instance.coi.network_interface.0.nat_ip_address
}
output "control_nodes" {
  value = yandex_compute_instance.kube_control_node.*.network_interface.0.nat_ip_address
}

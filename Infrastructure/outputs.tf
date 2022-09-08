output "control_nodes" {
  value = yandex_compute_instance.kube_control_node.*.network_interface.0.nat_ip_address
}

output "worker_nodes" {
  value = yandex_compute_instance.worker_node.*.network_interface.0.nat_ip_address
}

output "container_registry" {
  value = "cr.yandex/${yandex_container_registry.image-registry.id}"
}

# Необходимо получить созданный ключ для дальнейшей авторизации аккаунта k8s (https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_key)
output "k8s-sa-key" {
  value = {
    id                 = yandex_iam_service_account_key.k8s-sa-key.id
    service_account_id = yandex_iam_service_account_key.k8s-sa-key.service_account_id
    created_at         = yandex_iam_service_account_key.k8s-sa-key.created_at
    key_algorithm      = yandex_iam_service_account_key.k8s-sa-key.key_algorithm
    public_key         = yandex_iam_service_account_key.k8s-sa-key.public_key
    private_key        = yandex_iam_service_account_key.k8s-sa-key.private_key
  }
  sensitive = true
}

# Необходимо получить созданный ключ для дальнейшей авторизации аккаунта ci-cd (https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account_key)
output "ci-cd-key" {
  value = {
    id                 = yandex_iam_service_account_key.ci-cd-key.id
    service_account_id = yandex_iam_service_account_key.ci-cd-key.service_account_id
    created_at         = yandex_iam_service_account_key.ci-cd-key.created_at
    key_algorithm      = yandex_iam_service_account_key.ci-cd-key.key_algorithm
    public_key         = yandex_iam_service_account_key.ci-cd-key.public_key
    private_key        = yandex_iam_service_account_key.ci-cd-key.private_key
  }
  sensitive = true
}




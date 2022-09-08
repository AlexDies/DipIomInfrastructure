locals {
  # Задаем локальные переменные для ресурсов кластера k8s в зависимости от workspace
  k8s = {
    image_id = "fd8mfc6omiki5govl68h"
    preemptible = false
    disk_type   = "network-ssd"
    platform_id = "standard-v1"
    stage = {
      controls = {
        count = 1
        cpu = 2
        memory = 2
        core_fraction = 5
        disk_size = 10
      }
      workers = {
        count = 3
        cpu = 2
        memory = 2
        core_fraction = 5
        disk_size = 20
      }
    }
    prod = {
      controls = {
        count = 3
        cpu = 4
        memory = 3
        core_fraction = 20
        disk_size = 20
      }
      workers = {
        count = 3
        cpu = 2
        memory = 2
        core_fraction = 5
        disk_size = 30
      }
    }
  }
}  

resource "yandex_compute_instance" "kube_control_node" {
  count    = local.k8s[local.workspace].controls.count #3
  name     = "kube-control-node-${count.index}"
  platform_id = local.k8s.platform_id
  hostname = "kube-control-node-${count.index}"
  zone = local.networks[count.index - floor(count.index / length(local.networks)) * length(local.networks)].zone_name

  resources {
    cores         = local.k8s[local.workspace].controls.cpu
    memory        = local.k8s[local.workspace].controls.memory
    core_fraction = local.k8s[local.workspace].controls.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = local.k8s.image_id
      type     = local.k8s.disk_type
      size     = local.k8s[local.workspace].controls.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public[count.index - floor(count.index / length(local.networks)) * length(local.networks)].id
    nat       = true
  }

  scheduling_policy {
    preemptible = local.k8s.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}

# Создание инстанса для worker node k8s
resource "yandex_compute_instance" "worker_node" {
  count    = local.k8s[local.workspace].workers.count
  name     = "kube-worker-node-${count.index}"
  platform_id = local.k8s.platform_id
  hostname = "kube-worker-node-${count.index}"
  zone = local.networks[count.index - floor(count.index / length(local.networks)) * length(local.networks)].zone_name

  resources {
    cores         = local.k8s[local.workspace].workers.cpu
    memory        = local.k8s[local.workspace].workers.memory
    core_fraction = local.k8s[local.workspace].workers.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = local.k8s.image_id
      type     = local.k8s.disk_type
      size     = local.k8s[local.workspace].workers.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public[count.index - floor(count.index / length(local.networks)) * length(local.networks)].id
    nat       = true
  }

  scheduling_policy {
    preemptible = local.k8s.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}
# Создаем переменную для работы с workspace в TFC
variable "TFC_WORKSPACE_NAME" {
  type = string
  default = ""
}

locals {
  # If your backend is not Terraform Cloud, the value is ${terraform.workspace}
  # otherwise the value retrieved is that of the TFC_WORKSPACE_NAME with trimprefix
  workspace = var.TFC_WORKSPACE_NAME != "" ? trimprefix("${var.TFC_WORKSPACE_NAME}", "alexd-") : "${var.TFC_WORKSPACE_NAME}"

  name = {
    stage = "stage"
    prod = "prod"
  }

  # Задаем локальные переменные для подсетей
  networks = [
    {
      name = "a"
      zone_name = "ru-central1-a"
      subnet = ["192.168.10.0/24"]
    },
    {
      name = "b"
      zone_name = "ru-central1-b"
      subnet = ["192.168.20.0/24"]
    },
    {
      name = "c" 
      zone_name = "ru-central1-c"
      subnet = ["192.168.30.0/24"]
    }
  ]
}

resource "yandex_vpc_network" "alexdiplom-vpc" {
  name = "${local.name[local.workspace]}-vpc"
}

resource "yandex_vpc_subnet" "public" {
  count = length(local.networks)
  v4_cidr_blocks = local.networks[count.index].subnet
  zone           = local.networks[count.index].zone_name
  network_id     = "${yandex_vpc_network.alexdiplom-vpc.id}"
  name           = "${local.networks[count.index].name}-subnet"
}




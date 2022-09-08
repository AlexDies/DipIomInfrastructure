terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.73.0"
    }
  }
 
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alexdies-homework"

    workspaces {
      prefix = "alexd-"
    }
  }

}


provider "yandex" {
  cloud_id  = "b1gg82n3pv24j3d9qihs"
  folder_id = "b1g8p0oqeo4nim4ua3js"
  zone      = "ru-central1-a"
}





### 1. Terrasform Cloud

За основу берем статью по ссылке: https://medium.com/@lichnguyen/using-terraform-workspace-with-terraform-cloud-993c31c1f8bc

Создано вручную два workspace - `alexd-stage` и `alexd-prod` для работы с `backend` `terraform`.

Для того чтобы работать с несколькими `workspace` в `Terraform Cloud` необходимо добавить 
следущий блок в основном `main.tf`:

```
variable "TFC_WORKSPACE_NAME" {
  type = string
  default = ""
}

locals {
  # If your backend is not Terraform Cloud, the value is ${terraform.workspace}
  # otherwise the value retrieved is that of the TFC_WORKSPACE_NAME with trimprefix
  workspace = var.TFC_WORKSPACE_NAME != "" ? trimprefix("${var.TFC_WORKSPACE_NAME}", "alexd-") : "${var.TFC_WORKSPACE_NAME}"
```
А также использование prefix в `versions.tf`:
```
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alexdies-homework"

    workspaces {
      prefix = "alexd-" 
    }
  }
```
Где `prefix = "alexd-"`- это префикс для определения ранее созданных `workspace` в `TFC`

Используем `token` `TF_TOKEN_app_terraform_io` для подключения к TFC командой `terraform login` 

```
TF_TOKEN_app_terraform_io=HoRWnucYZFXHLA.atlasv1.3Z9n58PNAens5eMDIr76zLLk9OZ69fDKOMhF6Hz8pevfKgrFXBhjPjzChxxEuTEjT2Y
```

Создаем `workspace` `prod` и `stage` с помощью команды `terraform workspace new prod` и `terraform workspace new stage`. Переключение осуществляется с помощью команды `terraform workspace select {x}`.

По итогу у нас есть два `workspace` `prod` и `stage`:
```
terraform workspace list
  prod
* stage
```

При запуске `terraform init` хранение `.tfstate` и дальнейшая работа будет происходить в `wokspace alexd-prod` (если выбран `wokspace prod`) или `wokspace alexd-stage` (если выбран `wokspace stage`).

### 2. Создание аккаунта для Terraform

2.1 Создаем `service account` для `terraform`:

```
yc iam service-account create terraform

id: ajekarlmhnn3srrqn23a
folder_id: b1g8p0oqeo4nim4ua3js
created_at: "2022-09-06T18:28:08.285273034Z"
name: terraform
```

2.2 Добавление роли для `service account` `terraform` в стандартный каталог `default`:

Добавим роль editor

```
yc resource-manager folder add-access-binding default --role editor --subject serviceAccount:ajekarlmhnn3srrqn23a

done (1s)
```
Добавим роль `editor`

2.3 Добавляем к ней ключ и запсиываем его в отдельный файл `key.json`

```
yc iam key create --service-account-id=ajekarlmhnn3srrqn23a --output key.json

id: ajet2k86qmfggj5m9dsu
service_account_id: ajekarlmhnn3srrqn23a
created_at: "2022-09-06T19:14:44.374314518Z"
key_algorithm: RSA_2048
```

(дополнительно) 2.4 Указываем `service_account_key_file` в блоке `provide` для использования terraform созданным ранее `service account`:

```
provider "yandex" {
  service_account_key_file = file("key.json")
  cloud_id  = "b1gg82n3pv24j3d9qihs"
  folder_id = "b1g8p0oqeo4nim4ua3js"
  zone      = "ru-central1-a"
}
```

2.5 Добавить ключ из `json` в переменную `YC_SERVICE_ACCOUNT_KEY_FILE` в `TFC` как переменную ENV и делаем её скрытной:

Так как в TFC в ENV окружение переменная должна быть одной строкой, то необходимо убрать все переносы строк, сделать это можно следующей командой:

`tr -d '\n' key.json > newkey.json`

Далее добавляем переменную `YC_SERVICE_ACCOUNT_KEY_FILE` в категории `Environment variable` и указываем значение `newkey.json`
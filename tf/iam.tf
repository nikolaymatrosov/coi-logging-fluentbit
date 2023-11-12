resource "yandex_iam_service_account" "logger" {
  name      = "coi-logger"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_binding" "logger" {
  for_each = toset([
    "logging.writer",
    "container-registry.images.puller"
  ])
  role      = each.value
  folder_id = var.folder_id
  members   = [
    "serviceAccount:${yandex_iam_service_account.logger.id}",
  ]
  sleep_after = 5
}

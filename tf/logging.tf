resource "yandex_logging_group" "coi" {
  name      = "coi-logging-group"
  folder_id = var.folder_id
}
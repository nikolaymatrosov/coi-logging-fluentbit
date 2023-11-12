resource "yandex_container_registry" "coi-logging" {
  name = "coi-logging"
}

data "external" "git_hash" {
  program = [
    "git",
    "log",
    "--pretty={\"sha\":\"%H\"}",
    "-1",
    "HEAD"
  ]
}

locals {
  image_name = "cr.yandex/${yandex_container_registry.coi-logging.id}/log-emitter:${data.external.git_hash.result.sha}"
}

resource "null_resource" "build" {
  triggers = {
    git_sha = data.external.git_hash.result.sha
  }

  provisioner "local-exec" {
    command = "cd .. && docker build --platform linux/amd64 -t ${local.image_name} . && docker push ${local.image_name}"
  }
}

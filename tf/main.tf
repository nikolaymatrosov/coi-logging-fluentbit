data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "coi" {
  name        = "coi-logging"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.coi.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.coi-a.id
    nat       = true
    ipv4      = true
  }

  service_account_id = yandex_iam_service_account.logger.id

  metadata = {
    ssh-keys       = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    docker-compose = templatefile("../spec.yaml", {
      YC_GROUP_ID = yandex_logging_group.coi.id,
      IMAGE       = local.image_name
    })
    user-data = data.cloudinit_config.user-data.rendered
  }
  depends_on = [
    yandex_iam_service_account.logger,
    yandex_logging_group.coi,
    yandex_vpc_subnet.coi-a,
    null_resource.build
  ]
}

resource "yandex_vpc_network" "coi" {}

resource "yandex_vpc_subnet" "coi-a" {
  zone           = var.zone
  network_id     = "${yandex_vpc_network.coi.id}"
  v4_cidr_blocks = ["10.5.0.0/24"]
}
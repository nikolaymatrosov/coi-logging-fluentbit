data "cloudinit_config" "user-data" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("../user-data.yaml", {
      SSH_PUBLIC_KEY = file("~/.ssh/id_rsa.pub")
      YC_GROUP_ID    = yandex_logging_group.coi.id
    })
  }
}
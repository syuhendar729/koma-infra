# Modul 03 — stack aplikasi. Ikuti naskah Bagian B dan C.

# Stack aplikasi membaca stack jaringan hanya lewat output-nya (kontrak antarstack).
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../m03-network/terraform.tfstate"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  awalan     = "koma-${var.nim}-m03"
  jaringan   = data.terraform_remote_state.network.outputs
  aplikasi   = base64gzip(file("${path.module}/../../app/koma_api.py"))
  web        = { for i in range(var.jumlah_web) : "web-${i + 1}" => i }
  cloud_init = { for peran, port in { web = 80, db = 5432 } : peran => templatefile("${path.module}/templates/cloud-init.yaml.tftpl", { versi = var.versi, peran = peran, port = port, aplikasi_gz = local.aplikasi }) }
}

# TODO B.1  tiga security group: alb, web, db (vpc_id = local.jaringan.vpc_id, tag peran)
# TODO B.2  aturan: alb masuk 80 dari var.cidr_saya; alb keluar 80 ke SG web;
#           web masuk 80 dari SG alb; web keluar 5432 ke SG db; db masuk 5432 dari SG web
# TODO C.1  aws_instance.web (for_each = local.web, subnet privat, tanpa IP publik, SG web,
#           user_data = local.cloud_init["web"]) dan aws_instance.db (SG db, cloud_init["db"])
# TODO C.2  aws_lb.app (application, publik, SG alb, subnet publik), aws_lb_target_group.web
#           (health check /health), aws_lb_target_group_attachment.web, aws_lb_listener.http

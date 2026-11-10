# Modul 02 — server sebagai kode: panggang (bake) AMI lalu sajikan (serve).
# Ikuti naskah Bagian B (panggang) dan C (sajikan).

locals {
  awalan = "koma-${var.nim}-m02"
  cloud_init = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    versi       = var.versi
    aplikasi_gz = base64gzip(file("${path.module}/../../app/koma_api.py"))
  })
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_vpc" "bawaan" {
  default = true
}

data "aws_availability_zones" "tersedia" {
  state = "available"
}

data "aws_subnet" "bawaan" {
  default_for_az    = true
  availability_zone = data.aws_availability_zones.tersedia.names[0]
}

resource "aws_instance" "pembangun" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.bawaan.id
  associate_public_ip_address = false
  user_data                   = local.cloud_init
  user_data_replace_on_change = true

  tags = {
    Name  = "${local.awalan}-pembangun"
    peran = "pembangun"
    versi = var.versi
  }
}

resource "time_sleep" "tunggu_cloud_init" {
  create_duration = var.tunggu_cloud_init
  triggers = {
    pembangun_id = aws_instance.pembangun.id
  }
}

resource "aws_ami_from_instance" "api" {
  name               = "${local.awalan}-api-${var.versi}"
  source_instance_id = aws_instance.pembangun.id
  depends_on         = [time_sleep.tunggu_cloud_init]

  tags = {
    Name  = "${local.awalan}-api-${var.versi}"
    peran = "api"
    versi = var.versi
  }
}

resource "aws_security_group" "api" {
  name        = "${local.awalan}-api"
  description = "HTTP API M02 dari IP praktikan"
  vpc_id      = data.aws_vpc.bawaan.id

  tags = {
    Name  = "${local.awalan}-api"
    peran = "api"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_saya" {
  security_group_id = aws_security_group.api.id
  cidr_ipv4         = var.cidr_saya
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_instance" "api" {
  ami                         = aws_ami_from_instance.api.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.bawaan.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.api.id]

  tags = {
    Name  = "${local.awalan}-api"
    peran = "api"
    versi = var.versi
  }
}

resource "aws_instance" "goreng" {
  count                       = var.bandingkan_goreng ? 1 : 0
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.bawaan.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.api.id]
  user_data                   = local.cloud_init
  user_data_replace_on_change = true

  tags = {
    Name  = "${local.awalan}-goreng"
    peran = "goreng"
    versi = "2.1.0"
  }
}

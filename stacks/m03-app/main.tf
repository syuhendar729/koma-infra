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

resource "aws_security_group" "alb" {
  name   = "${local.awalan}-alb"
  vpc_id = local.jaringan.vpc_id
  tags   = { Name = "${local.awalan}-alb", peran = "alb" }
}

resource "aws_security_group" "web" {
  name   = "${local.awalan}-web"
  vpc_id = local.jaringan.vpc_id
  tags   = { Name = "${local.awalan}-web", peran = "web" }
}

resource "aws_security_group" "db" {
  name   = "${local.awalan}-db"
  vpc_id = local.jaringan.vpc_id
  tags   = { Name = "${local.awalan}-db", peran = "db" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_dari_laptop" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = var.cidr_saya
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_ke_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_dari_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_ke_db" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_dari_web" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_instance" "web" {
  for_each                    = local.web
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = local.jaringan.subnet_privat_ids[each.value % length(local.jaringan.subnet_privat_ids)]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data                   = local.cloud_init.web
  user_data_replace_on_change = true
  tags                        = { Name = "${local.awalan}-${each.key}", peran = "web", versi = var.versi }
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = local.jaringan.subnet_privat_ids[0]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.db.id]
  user_data                   = local.cloud_init.db
  user_data_replace_on_change = true
  tags                        = { Name = "${local.awalan}-db", peran = "db", versi = var.versi }
}

resource "aws_lb" "app" {
  name               = "${local.awalan}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.jaringan.subnet_publik_ids
  tags               = { Name = "${local.awalan}-alb", peran = "alb" }
}

resource "aws_lb_target_group" "web" {
  name     = "${local.awalan}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.jaringan.vpc_id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "${local.awalan}-web", peran = "web" }
}

resource "aws_lb_target_group_attachment" "web" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web.arn
        weight = 1
      }
    }
  }
}

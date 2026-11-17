# Modul 03 — stack jaringan. Ikuti naskah Bagian A.

data "aws_availability_zones" "ada" {
  state = "available"
}

locals {
  awalan = "koma-${var.nim}-m03"
  # Dua AZ pertama; kunci peta = huruf akhir nama AZ (a, b) agar nama resource stabil.
  azs = { for i, az in slice(data.aws_availability_zones.ada.names, 0, 2) : substr(az, -1, 1) => { az = az, i = i } }
}

resource "aws_vpc" "utama" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.awalan}-vpc" }
}

resource "aws_default_security_group" "bawaan" {
  vpc_id = aws_vpc.utama.id

  ingress = []
  egress  = []
  tags    = { Name = "${local.awalan}-default-deny" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.utama.id
  tags   = { Name = "${local.awalan}-igw" }
}

resource "aws_subnet" "publik" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.utama.id
  availability_zone       = each.value.az
  cidr_block              = cidrsubnet(var.cidr_vpc, 8, each.value.i)
  map_public_ip_on_launch = false
  tags = {
    Name = "${local.awalan}-publik-${each.key}"
    tier = "publik"
  }
}

resource "aws_subnet" "privat" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.utama.id
  availability_zone       = each.value.az
  cidr_block              = cidrsubnet(var.cidr_vpc, 8, each.value.i + 10)
  map_public_ip_on_launch = false
  tags = {
    Name = "${local.awalan}-privat-${each.key}"
    tier = "privat"
  }
}

resource "aws_route_table" "publik" {
  vpc_id = aws_vpc.utama.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${local.awalan}-rt-publik" }
}

resource "aws_route_table" "privat" {
  vpc_id = aws_vpc.utama.id
  tags   = { Name = "${local.awalan}-rt-privat" }
}

resource "aws_route_table_association" "publik" {
  for_each       = aws_subnet.publik
  subnet_id      = each.value.id
  route_table_id = aws_route_table.publik.id
}

resource "aws_route_table_association" "privat" {
  for_each       = aws_subnet.privat
  subnet_id      = each.value.id
  route_table_id = aws_route_table.privat.id
}

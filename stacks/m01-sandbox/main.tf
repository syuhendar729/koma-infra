# Modul 01 — stack sandbox untuk katalog layanan kasus.

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "default" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = aws_default_subnet.default.vpc_id
}

resource "aws_network_interface" "layanan" {
  for_each        = var.layanan
  subnet_id       = aws_default_subnet.default.id
  security_groups = [data.aws_security_group.default.id]
}

resource "aws_instance" "layanan" {
  for_each = var.layanan

  ami           = data.aws_ami.al2023.id
  instance_type = each.value.ukuran

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.layanan[each.key].id
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name  = "koma-${var.nim}-m01-${each.key}"
    peran = each.value.peran
  }
}

# Refaktor dari resource tunggal ke katalog for_each tanpa mengganti instance web.
moved {
  from = aws_instance.web
  to   = aws_instance.layanan["portal-pasien"]
}

moved {
  from = aws_network_interface.web
  to   = aws_network_interface.layanan["portal-pasien"]
}

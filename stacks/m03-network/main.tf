# Modul 03 — stack jaringan. Ikuti naskah Bagian A.

data "aws_availability_zones" "ada" {
  state = "available"
}

locals {
  awalan = "koma-${var.nim}-m03"
  # Dua AZ pertama; kunci peta = huruf akhir nama AZ (a, b) agar nama resource stabil.
  azs = { for i, az in slice(data.aws_availability_zones.ada.names, 0, 2) : substr(az, -1, 1) => { az = az, i = i } }
}

# TODO A.1  aws_vpc.utama (var.cidr_vpc, DNS support + hostnames) dan
#           aws_default_security_group.bawaan (dikosongkan: default-deny)
# TODO A.2  aws_internet_gateway.igw
# TODO A.3  aws_subnet.publik dan aws_subnet.privat (for_each = local.azs;
#           cidrsubnet(var.cidr_vpc, 8, i) dan (.., i + 10); map_public_ip_on_launch = false;
#           tag tier = "publik" / "privat")
# TODO A.4  aws_route_table.publik (0.0.0.0/0 -> IGW), aws_route_table.privat (TANPA rute keluar,
#           tanpa NAT Gateway), dan aws_route_table_association untuk keduanya

output "vpc_id" {
  value = aws_vpc.utama.id
}

output "cidr_vpc" {
  value = var.cidr_vpc
}

output "subnet_publik_ids" {
  value = [for k in sort(keys(aws_subnet.publik)) : aws_subnet.publik[k].id]
}

output "subnet_privat_ids" {
  value = [for k in sort(keys(aws_subnet.privat)) : aws_subnet.privat[k].id]
}

output "instance" {
  value = {
    for k, layanan in aws_instance.layanan : k => {
      id         = layanan.id
      ip_private = layanan.private_ip
      tipe       = layanan.instance_type
      peran      = layanan.tags.peran
    }
  }
}

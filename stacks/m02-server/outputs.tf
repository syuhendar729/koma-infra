output "url_api" {
  value = "http://${aws_instance.api.public_ip}"
}

output "ami" {
  value = {
    id   = aws_ami_from_instance.api.id
    nama = aws_ami_from_instance.api.name
  }
}

output "versi" {
  value = var.versi
}

output "url_goreng" {
  value = var.bandingkan_goreng ? "http://${aws_instance.goreng[0].public_ip}" : null
}

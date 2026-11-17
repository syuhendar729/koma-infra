output "url_lb" {
  value = "http://${aws_lb.app.dns_name}"
}

output "ip_privat" {
  value = merge(
    { for k, v in aws_instance.web : k => v.private_ip },
    { db = aws_instance.db.private_ip }
  )
}

resource "aws_vpc_security_group_ingress_rule" "salah_db_dari_alb" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "salah_web_dari_internet" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

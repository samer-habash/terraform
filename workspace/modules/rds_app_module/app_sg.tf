resource "aws_security_group" "app_sg" {
  name = join("-", [module.shared_vars.rds_project_name_vars, "app-sg"])
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress_allow_all_app" {
  security_group_id = aws_security_group.app_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = -1
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "egress_allow_all_app" {
  from_port         = 0
  protocol          = "TCP"
  security_group_id = aws_security_group.app_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

// connect the load balancer to the app using 8080
resource "aws_security_group_rule" "allow-all-to-loadBalancer-8080" {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  security_group_id = aws_security_group.app_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  type = "ingress"
}
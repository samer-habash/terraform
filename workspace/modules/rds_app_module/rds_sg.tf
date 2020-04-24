resource "aws_security_group" "rds_sg" {
  name = join("-", [module.shared_vars.rds_project_name_vars, "sg"])
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress_allow_all_rds" {
  security_group_id = aws_security_group.rds_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = -1
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "egress_allow_all_rds" {
  from_port         = 0
  protocol          = "TCP"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "allow-from-app-to-rds" {
  from_port = module.shared_vars.project_rds_internal_dbport
  to_port   = module.shared_vars.project_rds_external_dbport
  protocol  = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.app_sg.id
  type = "ingress"
}


module "shared_vars" {
  source = "../../projects/projects_shared_vars"
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  // If we use identifier it will overwrite the instance_id of the db instance,
  //we should use in elb to get the instance_identifier and no the instacne_id
  identifier           = "generic-mysql-instances"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = "bookstack"
  username             = "bookstack"
  // I will generate random pass
  password             = module.shared_vars.rds_random_pass_generation
  // password             = "secret123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.project_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
}

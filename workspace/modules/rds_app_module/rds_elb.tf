resource "aws_elb" "app_elb" {
  // only alphanumeric characters and hyphens allowed in "name" , I used dash join instead
  name = join("-", [module.shared_vars.project_rds_app_name, "elb"])
  // I grab it from the amazon GUI , I could not grab the instance ID after created by launch template
  // No need to make instances because it will be loaded automatically via auto_scaling_group attachement
  // instances = []
  availability_zones = [data.aws_subnet.rds_subnet_id_1.availability_zone, data.aws_subnet.rds_subnet_id_2.availability_zone]
  // security groups default+app
  security_groups = [data.aws_security_group.default.id, aws_security_group.app_sg.id]
  listener {
    // lb port is 8080 and Instance Port 8080 , while inside the instance the contianer port is 80
    instance_port = module.shared_vars.project_rds_lb_port
    instance_protocol = "tcp"
    lb_port = module.shared_vars.project_rds_lb_port
    lb_protocol = "tcp"
  }
}


//resource "aws_instance" "elb_instance" {
//  ami = ""
//  instance_type = ""
//}

resource "aws_elb" "rds_elb" {
  // only alphanumeric characters and hyphens allowed in "name" , I used dash join instead
  name = join("-", [module.shared_vars.rds_project_name_vars, "elb"])
  // I grab it from the amazon GUI , I could not grab the instance ID after created by launch template
  instances = ["i-0e5e8819a36f51b74"]
  availability_zones = [aws_db_instance.rds_instance.availability_zone]
  security_groups = [aws_security_group.project_sg.id]
  // I will attach it only on the rds sg .
  source_security_group = data.aws_security_group.default.id
  listener {
    instance_port = 3306
    instance_protocol = "tcp"
    lb_port = 3306
    lb_protocol = "tcp"
  }
}

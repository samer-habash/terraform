data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "rds_subnet_id_1" {
  availability_zone = "us-east-1a"
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "rds_subnet_id_2" {
  availability_zone = "us-east-1b"
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  name = "default"
}
// Tried to grab the instance ID created by launch template, no luck
//data "aws_instances" "Grab_launch_template_ec2_instances" {
//  filter {
//    name   = "instance.group-id"
//    values = [aws_security_group.project_sg.id, data.aws_security_group.default.id]
//  }
//  instance_tags = {
//
//  }
//  instance_state_names = ["running"]
//}
resource "aws_launch_template" "rds_lt" {
  name = join("-", [module.shared_vars.rds_project_name_vars, "lt"])
  image_id = "ami-0b898040803850657"
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.project_sg.id]
  // user data grabbed from project variables in general
  user_data = base64encode(module.shared_vars.project_rds_user_data)
  iam_instance_profile {
    name = "lt_rds_instances"
  }
}

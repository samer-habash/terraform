resource "aws_launch_template" "app_lt" {
  name = join("-", [module.shared_vars.project_rds_app_name, "lt"])
  image_id = "ami-0b898040803850657"
  instance_type = "t2.micro"
  // security groups default+app
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.app_sg.id]
  // user data base64 grabbed user_data file
  user_data = base64encode(data.template_file.user_data_lt.rendered)
}
resource "aws_autoscaling_group" "app_auto_scale" {
  name = join("-", [module.shared_vars.project_rds_app_name, "asg"])
  max_size = 3
  min_size = 1
  desired_capacity = 2
  force_delete = true
  health_check_type  = "EC2"
  // Add the two subnets
  vpc_zone_identifier = [data.aws_subnet.rds_subnet_id_1.id, data.aws_subnet.rds_subnet_id_2.id]
  availability_zones = [data.aws_subnet.rds_subnet_id_1.availability_zone, data.aws_subnet.rds_subnet_id_2.availability_zone]
  launch_template {
    id = aws_launch_template.app_lt.id
    // Sync with latest version of template if there will be future changes
    version = aws_launch_template.app_lt.latest_version
  }
}

# Attach the load balancer auto_scaling group
resource "aws_autoscaling_attachment" "asg_attach_app_elb" {
  autoscaling_group_name = aws_autoscaling_group.app_auto_scale.name
  elb                    = aws_elb.app_elb.id
}

# Add asg policy
resource "aws_autoscaling_policy" "rds_asg_policy" {
  name = join("-", [module.shared_vars.rds_project_name_vars, "asg-policy"])
  scaling_adjustment = 3
  autoscaling_group_name = aws_autoscaling_group.app_auto_scale.name
  cooldown = 300
  // it is a free tier , I chose to be exact capacity and not to maximize the capacity
  adjustment_type = "ExactCapacity"
}
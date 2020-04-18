###############
# Global & Prequests      #
###############
//Run
//export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"

provider "aws" {
  region = "us-east-1"
}

// Grab the aws vpc default for region
data "aws_vpc" "default" {
  default = true
}

// Grab security_defauly group
data "aws_security_group" "default" {
  name = "default"
}

// Grab the us-east-1a subnet
data "aws_subnet" "subnet_east1a" {
  default_for_az = true
  availability_zone = "us-east-1a"
}

data "aws_availability_zone" "zone_us-east-1a" {
  name = "us-east-1a"
}

###############
# Task 1      #
###############

resource "aws_security_group" "dokuwiki-sg" {
  name = "dokuwiki-sg"
  description = "Allow Port 80 inbound traffic"
}

// New Syntax :
//Terraform 0.11 and earlier required all non-constant expressions to be
//provided via interpolation syntax, but this pattern is now deprecated. To
//silence this warning, remove the "${ sequence from the start and the }"

data "aws_security_group" "dokuwiki-data" {
  id = aws_security_group.dokuwiki-sg.id
}

resource "aws_security_group_rule" "inbound" {
  description = "Allowing Port 80 from all over the world"
  type = "ingress"
  from_port = 80
  protocol = "TCP"
  to_port = 80
  security_group_id = data.aws_security_group.dokuwiki-data.id
  cidr_blocks = ["0.0.0.0/0"]
}

###############
# Task 2      #
###############

resource "aws_instance" "dokuwiki_instance" {
  // aws does not apply the instance name as "dokuwiki_instance" , it will be empty in real GUI web
  ami = "ami-0915e09cc7ceee3ab"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/usr/bin/bash
              yum install docker -y
              systemctl enable docker
              systemctl start docker
              docker run -d -p 80:80 --name dokuwiki bitnami/dokuwiki:latest
  EOF
  security_groups = ["default", "dokuwiki-sg"]
  // Or By ID's (But there is no way to grab the  security_group_id for the default one - resource "aws_default_security_group" doesn not exist anymore)
  //NOTE From terraform Doc: If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  #vpc_security_group_ids = [aws_security_group.dokuwiki-sg.id, data.aws_security_group.default.id]
}

###############
# Task 3      #
###############

/*
 I have tried to directly attach the instance created above to the autscaling group with resource "aws_autoscaling_attachment"
 but at the moment it can attach Load Balancers only to auto_scale_groups.
 e.g :-
 // Getting the data after auto_scaling_group created
data "aws_autoscaling_group" "dokuwiki_autoscaling_data" {
  id = aws_autoscaling_group.dokuwiki_autoscaling.id
  name = aws_autoscaling_group.dokuwiki_autoscaling.name
}
  // attaching upon the autoscaling_group name or id
resource "aws_autoscaling_attachment" "dokuwiki_autoscaling_attach" {
  autoscaling_group_name = data.aws_autoscaling_group.dokuwiki_autoscaling_data.name
}
*/

resource aws_launch_configuration "dokuwiki_launch_conf" {
  name = "dokuwiki_launch_conf"
  // Map the ami and instance_type from above to be more dynamic way
  image_id      = aws_instance.dokuwiki_instance.ami
  instance_type = aws_instance.dokuwiki_instance.instance_type
  user_data = aws_instance.dokuwiki_instance.user_data
  security_groups = [data.aws_security_group.default.id, aws_security_group.dokuwiki-sg.id]
}

resource "aws_autoscaling_group" "dokuwiki_autoscaling" {
  name = "dokuwiki_autoscaling"
  // By default terraform will wait for the auto_scale_group to wait for the instances to run ,
  force_delete = true // terraform will stop when creating the auto_scale_group only.
  max_size = 3
  min_size = 1
  desired_capacity = 2
  // Terraform Doc : The parameter availability_zones should not be specified when using vpc_zone_identifier
  availability_zones = [data.aws_availability_zone.zone_us-east-1a.name]
  // Map the cidr from the defualt aws_vpc from above , could not do it automatic since the "vpc_zone_identifier" is a lits
  // From the doc : "vpc_zone_identifier (Optional) A list of subnet IDs to launch resources in."
  vpc_zone_identifier  = [data.aws_subnet.subnet_east1a.id]
  launch_configuration = aws_launch_configuration.dokuwiki_launch_conf.id
}
###############
# BONUS
# 1. Define the following resources with terraform:
# a. Define a new VPC with 2 subnets on us-east-1 region
# b. Define the project above in the VPC you just created
###############

//Run
//export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dokuwiki_vpc" {
  // If a new vpc is created , it will create a default security group for its own by default.
  // So we will use the default security group created in the securtiy group .
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
}

resource "aws_subnet" "dokuwiki_subnet_a" {
  vpc_id = aws_vpc.dokuwiki_vpc.id
  cidr_block = "10.0.80.0/24"
}

resource "aws_subnet" "dokuwiki_subnet_b" {
  vpc_id = aws_vpc.dokuwiki_vpc.id
  cidr_block = "10.0.100.0/24"
}

// Add internet gateway for "dokuwiki_vpc"
resource "aws_internet_gateway" "dokuwiki_ig" {
  vpc_id = aws_vpc.dokuwiki_vpc.id
}

// Security Group
resource "aws_security_group" "dokuwiki-sg" {
  name = "dokuwiki-sg"
  description = "Allow Port 80 inbound traffic"
  // we should assign the dokuwiki-sg to the new vpc "dokuwiki_vpc"
  vpc_id = aws_vpc.dokuwiki_vpc.id

}

resource "aws_security_group_rule" "inbound" {
  description = "Allowing Port 80 from all over the world"
  type = "ingress"
  from_port = 80
  protocol = "TCP"
  to_port = 80
  security_group_id = ""
  cidr_blocks = ["0.0.0.0/0"]
}

###############
# Task 2      #
###############

resource "aws_instance" "dokuwiki_instance" {
  // aws does not apply the instance name as "dokuwiki_instance" , it will be empty in real GUI web
  ami = "ami-0915e09cc7ceee3ab"
  instance_type = "t2.micro"
  // This is very important to match the subnets created above
  subnet_id = aws_subnet.dokuwiki_subnet_a.id
  user_data = <<-EOF
              #!/usr/bin/bash
              yum install docker -y
              systemctl enable docker
              systemctl start docker
              docker run -d -p 80:80 --name dokuwiki bitnami/dokuwiki:latest
  EOF
  // Here we will add the default security group id created by VPC  "dokuwiki_vpc" + the ID of "dokuwiki-sg"
  vpc_security_group_ids = [aws_vpc.dokuwiki_vpc.default_security_group_id, aws_security_group.dokuwiki-sg.id]
}

###############
# Task 3      #
###############

// I used launch template for variety setup
resource "aws_launch_template" "dokuwiki_launch_template" {
  name = "dokuwiki_launch_template"
  image_id = aws_instance.dokuwiki_instance.ami
  instance_type = aws_instance.dokuwiki_instance.instance_type
  vpc_security_group_ids = [aws_vpc.dokuwiki_vpc.default_security_group_id, aws_security_group.dokuwiki-sg.id]
  user_data = base64encode(file("instance_init_script.sh"))
}

resource "aws_autoscaling_group" "dokuwiki_autoscaling" {
  name = "dokuwiki_autoscaling"
  // By default terraform will wait for the auto_scale_group to wait for the instances to run ,
  force_delete = true // terraform will stop when creating the auto_scale_group only.
  max_size = 3
  min_size = 1
  desired_capacity = 2
  vpc_zone_identifier  = [aws_subnet.dokuwiki_subnet_a.id, aws_subnet.dokuwiki_subnet_b.id]
  launch_template {
    id = aws_launch_template.dokuwiki_launch_template.id
  }
}

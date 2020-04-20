/*
Added workspace and select it.
~ cd Lesson9/workspace/projects/rds && terraform workspace new developmet
terraform workspace select development
NOTE: you have to switch to workspace development , otherwise it cannot get the default workspace name.
*/

provider "aws" {
  region = "us-east-1"
}

module "ec2_rds" {
  source = "../../modules/ec2_rds"
}
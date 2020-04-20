resource "aws_db_subnet_group" "rds_subnet" {
  name = join("-", [module.shared_vars.rds_project_name_vars, "subnet"])
  /*All subnets for region us-east-1, to fix also issue :
  Error creating DB Subnet Group: DBSubnetGroupDoesNotCoverEnoughAZs: DB Subnet Group doesn't meet availability zone
  coverage requirement. Please add subnets to cover at least 2 availability zones. Current coverage: 1
  since it needs two subnets as required*/
  subnet_ids = [data.aws_subnet.rds_subnet_id_1.id, data.aws_subnet.rds_subnet_id_2.id]
}


output "rds_project_name_vars" {
  value = join("-", [local.env, local.project_name.rds.name])
}

output "rds_project_dbname" {
  value = local.project_name.rds.dbname
}

output "rds_project_dbuser" {
  value = local.project_name.rds.dbuser
}

output "project_rds_internal_dbport" {
  value = local.project_name.rds.db_port
}

output "project_rds_external_dbport" {
  value = local.project_name.rds.external_db_port
}

output "project_rds_app_name" {
  value = local.project_name.rds.app_name
}

output "project_rds_app_port" {
  value = local.project_name.rds.app_port
}

output "project_rds_app_container_port" {
  value = local.project_name.rds.app_container_port
}

output "project_rds_lb_port" {
  value = local.project_name.rds.lb_port
}

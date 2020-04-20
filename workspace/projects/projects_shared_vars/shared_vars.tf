// Shared local vars accros multiple projects

locals {
  env = terraform.workspace
  project_name = {
    rds = {
      name = "rds"
      dbname = "bookstack"
      dbuser = "bookstack"
      // we will use random generate random pass
      db_port = 3306
      external_db_port = 3306
      user_data = <<-EOF
                    #!/usr/bin/bash
                    yum install docker -y
                    systemctl enable docker
                    systemctl start docker
                    docker run -d \
                    -e DB_HOST=<the rds instance address>:3306 \
                    -e DB_DATABASE=bookstack \
                    -e DB_USERNAME=bookstack \
                    -e DB_PASSWORD=secret123 \
                    -p 8080:80 \
                    solidnerd/bookstack:0.27.5
EOF
    }
    // For another projects , etc ...
  }
}

output "rds_project_name_vars" {
  value = join("-", [local.env, local.project_name.rds.name])
}

output "project_rds_internal_dbport" {
  value = local.project_name.rds.db_port
}

output "project_rds_external_dbport" {
  value = local.project_name.rds.external_db_port
}

output "project_rds_user_data" {
  value = local.project_name.rds.user_data
}
data "template_file" "user_data_lt" {
  template = <<-EOF
              #!/usr/bin/bash
              yum install docker -y
              systemctl enable docker
              systemctl start docker
              docker run -d \
              -e DB_HOST=${aws_db_instance.rds_instance.address}:${module.shared_vars.project_rds_external_dbport} \
              -e DB_DATABASE=${module.shared_vars.rds_project_dbname} \
              -e DB_USERNAME=${module.shared_vars.rds_project_dbuser} \
              -e DB_PASSWORD=${aws_db_instance.rds_instance.password}\
              -p ${module.shared_vars.project_rds_lb_port}:${module.shared_vars.project_rds_app_container_port} \
              solidnerd/bookstack:0.27.5
EOF
}
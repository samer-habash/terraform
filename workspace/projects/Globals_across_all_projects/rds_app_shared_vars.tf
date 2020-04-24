// shared variable

locals {
  env = terraform.workspace
  project_name = {
    rds = {
      name = "rds"
      dbname = "bookstack"
      dbuser = "bookstack"
      // password is directly generated from rds_instance
      db_port = 3306
      external_db_port = 3306
      // App that will connect to RDS
      app_name: "bookstack"
      app_port: 8080
      app_container_port = 80
      // Load Balancer port
      lb_port = 8080
    }
    // For another projects , etc ...
  }
}
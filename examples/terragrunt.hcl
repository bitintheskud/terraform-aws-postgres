include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::git@github.com:bitintheskud/terraform-aws-postgres.git?ref=v1.0.5"
}

dependency "bastion" {
  config_path = "../bastion"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "ec2" {
  config_path = "../webserver"
}


locals {
  aws_region     = basename(dirname(get_terragrunt_dir()))
  project        = "project_code"
  identifier     = "web"
  env            = "development"
  custom_tags    = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("custom_tags_ecommerce.yaml")}"))
}


inputs = {
  project     = local.project
  aws_region  = local.aws_region
  identifier  = local.identifier
  custom_tags = local.custom_tags
  env         = local.env
  bastion_sg  = dependency.bastion.outputs.security_group_id
  vpc_id      = dependency.vpc.outputs.vpc_id
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids

  db = {
    "publicly_accessible" = true
    "port"                = "5432"
    "allowed_cidr_block" = []
    "allowed_security_group" = [ dependency.ec2.outputs.security_group_id,
      dependency.bastion.outputs.security_group_id ]
    "db_user"                 = "dbadmin"
    "backup_retention_period" = 7
    "publicly_available"      = false
    "engine"                  = "postgres"
    "family"                  = "postgres11"
    "engine_version"          = "11.5"
    "major_engine_version"    = "11"
    "instance_class"          = "db.t3.micro"
    "allocated_storage"       = 10
    "max_allocated_storage"   = 100
    "storage_encrypted"       = true
    "maintenance_window"      = "Mon:00:00-Mon:03:00"
    "backup_windows"          = "03:00-06:00"
    "deletion_protection"     = false
    "parameters" = [
      {
        name  = "rds.force_ssl"
        value = "0"
      }
    ]
  }
}
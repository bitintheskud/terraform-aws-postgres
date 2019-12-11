resource "random_string" "db_password" {
  length = 16
}

resource "random_string" "this_id" {
  length = 4
  upper = false
  special = false
}

locals {
  name_identifier = "${var.project}-${var.identifier}-db-${random_string.this_id.result}"

  # Only alphanumeric character in name
  db_name = "${var.project}${var.identifier}"
}

resource "aws_security_group" "db_allow_all" {
  name        = local.name_identifier
  description = "Allow all traffic to postgres instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db["port"]
    to_port     = var.db["port"]
    protocol    = "tcp"
    cidr_blocks = var.db["allowed_cidr_block"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = local.name_identifier

  engine            = "postgres"
  engine_version    = var.db["engine_version"]
  instance_class    = var.db["instance_class"]
  allocated_storage = var.db["allocated_storage"]
  storage_encrypted = var.db["storage_encrypted"]

  name = local.db_name

  username = var.db["db_user"]

  password = "${random_string.db_password.result}"
  port     = var.db["port"]

  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids = [ "${aws_security_group.db_allow_all.id}" ]

  maintenance_window = var.db["maintenance_window"]
  backup_window      = var.db["backup_windows"]

  # disable backups to create DB faster
  backup_retention_period = var.db["backup_retention_period"]

  tags = merge(
    var.custom_tags,
    {
      "Role" = var.identifier,
      "Environment" = var.env
    }
  )

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = var.db["family"]

  # DB option group
  major_engine_version = var.db["major_engine_version"]

  # Snapshot name upon DB deletion
  final_snapshot_identifier = local.name_identifier

  # Database Deletion Protection
  deletion_protection = var.db["deletion_protection"]

  # Database parameters 
  parameters = var.db["parameters"]
}

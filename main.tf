resource "random_string" "db_password" {
  length = 16
}

resource "random_string" "this_id" {
  length  = 4
  upper   = false
  special = false
}

locals {
  name_identifier = "${var.project}-${var.identifier}-db-${random_string.this_id.result}"

  # Only alphanumeric character in name
  db_name = "${var.identifier}"
}

resource "aws_security_group" "db_allow_all" {
  name        = local.name_identifier
  description = "Allow all traffic to postgres instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "db_allowed_cidr_block" {
  count             = var.db["allowed_cidr_block"] != [] ? 1 : 0
  from_port         = var.db["port"]
  protocol          = "tcp"
  security_group_id = aws_security_group.db_allow_all.id
  to_port           = var.db["port"]
  type              = "ingress"
  cidr_blocks       = var.db["allowed_cidr_block"]
}

resource "aws_security_group_rule" "db_allowed_security_group" {
  for_each = toset(var.db["allowed_security_group"])

  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_allow_all.id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = each.key
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = local.name_identifier

  engine                = "postgres"
  engine_version        = var.db["engine_version"]
  instance_class        = var.db["instance_class"]
  allocated_storage     = var.db["allocated_storage"]
  max_allocated_storage = var.db["max_allocated_storage"]
  storage_encrypted     = var.db["storage_encrypted"]

  name = local.db_name

  username = var.db["db_user"]

  password = "${random_string.db_password.result}"
  port     = var.db["port"]

  publicly_accessible = var.db["publicly_accessible"]

  vpc_security_group_ids = ["${aws_security_group.db_allow_all.id}"]

  maintenance_window = var.db["maintenance_window"]
  backup_window      = var.db["backup_windows"]

  # disable backups to create DB faster
  backup_retention_period = var.db["backup_retention_period"]

  tags = merge(
    var.custom_tags,
    {
      "Role"        = var.identifier,
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
  multi_az   = var.db["multi_az_enable"]

  apply_immediately = var.apply_immediately
}

resource "aws_db_instance" "replica" {
  count                  = var.db["replica"]["enable"] ? 1 : 0
  identifier             = "${local.name_identifier}-replica"
  instance_class         = var.db["instance_class"]
  replicate_source_db    = module.db.this_db_instance_id
  vpc_security_group_ids = ["${aws_security_group.db_allow_all.id}"]
  allocated_storage      = var.db["allocated_storage"]
  max_allocated_storage  = var.db["max_allocated_storage"]
  ca_cert_identifier     = var.db["ca_cert_identifier"]
  publicly_accessible    = var.db["publicly_accessible"]
  availability_zone = var.db["replica"]["availability_zone"]
  final_snapshot_identifier = "${local.name_identifier}-replica-snapshot"
}

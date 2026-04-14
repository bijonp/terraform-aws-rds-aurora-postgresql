#############################################
# Aurora PostgreSQL (Terraform) - main.tf
# Purpose: Production-style Aurora PostgreSQL cluster example
# Notes:
#  - No real secrets are committed
#  - Networking IDs are expected as variables (subnets, security group)
#############################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }
}

# --- Provider ---
provider "aws" {
  region = var.aws_region
}

# --- Cluster Parameter Group (cluster-level settings) ---
resource "aws_rds_cluster_parameter_group" "aurora_pg_cluster" {
  name        = "${var.name}-aurora-pg-cluster-pg"
  family      = var.cluster_family
  description = "Aurora PostgreSQL cluster parameter group managed by Terraform"

  # Example parameter — adjust for your standards
  parameter {
    name         = "rds.force_ssl"
    value        = var.force_ssl ? "1" : "0"
    apply_method = "immediate"
  }

  tags = var.tags
}

# --- DB Parameter Group (instance-level settings) ---
resource "aws_db_parameter_group" "aurora_pg_instance" {
  name        = "${var.name}-aurora-pg-instance-pg"
  family      = var.instance_family
  description = "Aurora PostgreSQL instance parameter group managed by Terraform"

  # Example: keep statement logging off by default
  parameter {
    name         = "log_min_duration_statement"
    value        = var.log_min_duration_ms
    apply_method = "immediate"
  }

  tags = var.tags
}

# --- Aurora Cluster ---
resource "aws_rds_cluster" "aurora_pg" {
  cluster_identifier = "${var.name}-aurora-pg"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password  # keep secret via tfvars/env; do NOT hardcode

  port = 5432

  # Networking
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Parameter groups
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg_cluster.name

  # Operational controls
  backup_retention_period      = var.backup_retention_days
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  deletion_protection          = true

  # Snapshot behavior
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name}-aurora-pg-final"

  # Encryption & logging
  storage_encrypted                 = true
  enabled_cloudwatch_logs_exports   = ["postgresql"]
  iam_database_authentication_enabled = var.iam_auth_enabled

  # Apply behavior
  apply_immediately = var.apply_immediately

  tags = merge(var.tags, {
    Component = "aurora-postgresql"
  })
}

# --- Aurora Instances (1 writer + (n-1) readers) ---
resource "aws_rds_cluster_instance" "aurora_pg_instances" {
  count = var.instance_count

  identifier         = "${var.name}-aurora-pg-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_pg.id

  engine         = aws_rds_cluster.aurora_pg.engine
  engine_version = aws_rds_cluster.aurora_pg.engine_version

  instance_class = var.instance_class

  # Instance parameter group (instance-level)
  db_parameter_group_name = aws_db_parameter_group.aurora_pg_instance.name

  publicly_accessible = false

  tags = merge(var.tags, {
    Role = count.index == 0 ? "writer" : "reader"
  })
}

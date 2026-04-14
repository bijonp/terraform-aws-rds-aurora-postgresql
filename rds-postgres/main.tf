 # Example AWS RDS PostgreSQL configuration
# Demonstrates production-style settings (HA, backups, maintenance)
# This file does not contain real credential

resource "aws_db_instance" "postgres" {
  identifier              = "example-postgres"
  engine                  = "postgres"
  engine_version          = "15.17" # example version
  instance_class          = "db.t3.medium"

  allocated_storage       = 100
  max_allocated_storage   = 200
  storage_type            = "gp3"

  db_name                 = "appdb"
  username                = "dbadmin"
  password                = "change-me" # placeholder only

  multi_az                = true
  publicly_accessible     = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:05:00-sun:06:00"

  skip_final_snapshot     = false
  deletion_protection     = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

---

# Example AWS RDS PostgreSQL configuration
# Demonstrates production-style settings (HA, backups, maintenance)
# This file does not contain real credentials

resource "aws_db_instance" "postgres" {
  identifier     = var.db_identifier
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.master_username
  password = var.master_password # placeholder via tfvars/env

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  # Networking (realistic production signals)
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  backup_retention_period = var.backup_retention_days
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  # Security & ops defaults
  storage_encrypted            = true
  deletion_protection          = true
  skip_final_snapshot          = false

  # Nice production signal (optional but recommended)
  performance_insights_enabled = true

  tags = var.tags
}

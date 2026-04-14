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

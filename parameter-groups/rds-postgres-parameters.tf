resource "aws_db_parameter_group" "rds_postgres" {
  name        = "${var.name}-rds-postgres-pg"
  family      = var.postgres_family
  description = "Custom RDS PostgreSQL DB parameter group (RDS, not Aurora)"
  tags        = var.tags

  # -----------------------------
  # Security / SSL
  # -----------------------------
  # Enforce SSL/TLS for all client connections
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # Recommended password hashing behavior (app compatibility scenarios)
  # NOTE: Only include if you need to control hashing algorithm behavior.
  # parameter {
  #   name  = "password_encryption"
  #   value = "scram-sha-256"
  # }

  # -----------------------------
  # Logging (good defaults for prod troubleshooting)
  # -----------------------------
  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # ms (log slow queries >= 1s)
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_temp_files"
    value = "10240" # KB (log temp files >= 10MB)
  }

  # Keep autovacuum messages visible enough for diagnosis without being too noisy
  parameter {
    name  = "log_autovacuum_min_duration"
    value = "10000" # ms


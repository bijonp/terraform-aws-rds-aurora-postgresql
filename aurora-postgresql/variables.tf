variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "name" {
  type        = string
  description = "Base name/prefix for resources"
  default     = "demo"
}

variable "engine_version" {
  type        = string
  description = "Aurora PostgreSQL engine version"
  default     = "15.7"
}

variable "database_name" {
  type        = string
  description = "Initial database name"
  default     = "appdb"
}

variable "master_username" {
  type        = string
  description = "Master username"
  default     = "dbadmin"
}

variable "master_password" {
  type        = string
  description = "Master password (do not commit real values)"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  type        = string
  description = "DB subnet group name for Aurora"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security group IDs for the cluster"
}

variable "instance_class" {
  type        = string
  description = "Instance class for Aurora instances"
  default     = "db.r6g.large"
}

variable "instance_count" {
  type        = number
  description = "Total number of instances (1 writer + readers)"
  default     = 2
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention in days"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "Preferred backup window"
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  type        = string
  description = "Preferred maintenance window"
  default     = "sun:05:00-sun:06:00"
}

variable "apply_immediately" {
  type        = bool
  description = "Apply modifications immediately"
  default     = false
}

variable "iam_auth_enabled" {
  type        = bool
  description = "Enable IAM database authentication"
  default     = false
}

variable "force_ssl" {
  type        = bool
  description = "Enforce SSL at cluster level (rds.force_ssl)"
  default     = false
}

variable "log_min_duration_ms" {
  type        = string
  description = "Log queries longer than this in ms (0 disables)"
  default     = "0"
}

variable "cluster_family" {
  type        = string
  description = "Aurora PostgreSQL cluster parameter group family"
  default     = "aurora-postgresql15"
}

variable "instance_family" {
  type        = string
  description = "Aurora PostgreSQL instance parameter group family"
  default     = "aurora-postgresql15"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default = {
    ManagedBy = "terraform"
  }
}

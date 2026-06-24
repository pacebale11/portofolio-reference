variable "project" {
  type        = string
  description = "GCP project id where CloudSQL instance will be located"
}

variable "instance_name" {
  type        = string
  description = "Name of the CloudSQL instance"
}

variable "master_instance_name" {
  type        = string
  description = "Name of the master CloudSQL instance that will be replicated to this instance"
  default     = null
}

variable "disk_size" {
  type        = number
  description = "Starting disk size for the CloudSQL instance"
  default     = 50
}

variable "disk_autoresize" {
  type        = bool
  description = "Specifies whether disk autoresize is enabled."
  default     = true
}

variable "cpu" {
  type        = number
  description = "Number of CPU"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Memory size in MB"
  default     = 4096
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "activation_policy" {
  type        = string
  description = "Specifies when the instance should be active. Can be either `ALWAYS`, `NEVER`, or `ON_DEMAND`."
  default     = "ALWAYS"

  validation {
    condition     = contains(["ALWAYS", "NEVER", "ON_DEMAND"], var.activation_policy)
    error_message = "Activation policy should be either `ALWAYS`, `NEVER`, or `ON_DEMAND`."
  }
}

variable "additional_database_flags" {
  type    = map(any)
  default = {}
  validation {
    condition = length(
      setintersection(keys(tomap(var.additional_database_flags)), ["cloudsql.iam_authentication", "cloudsql.logical_decoding"]),
    ) == 0
    error_message = "Use module enable_iam_authentication variable instead of additional_database_flags.cloudsql.iam_authentication\nand logical_decoding variable instead of additional_database_flags.cloudsql.logical_decoding."
  }
  description = "Key value pair of database flags that will be enabled"
}

variable "tier" {
  type        = string
  description = "Custom Cloud SQL instance tier."
  default     = null
}

variable "database_version" {
  type        = string
  description = "Version of postgresql"
  validation {
    condition     = contains(["POSTGRES_9_6", "POSTGRES_10", "POSTGRES_11", "POSTGRES_12", "POSTGRES_13", "POSTGRES_14", "POSTGRES_15"], var.database_version)
    error_message = "Database version must be in (POSTGRES_9_6, POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, POSTGRES_14, POSTGRES_15)."
  }
  default = "POSTGRES_13"
}

variable "environment" {
  type        = string
  description = "Environment to deploy into"
  validation {
    condition     = contains(["staging", "production", "development"], var.environment)
    error_message = "Environment must be in (staging, production, development)."
  }
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Instance labels"
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "the instance have public ip or not"
}

variable "authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of IP addresses to be allowed access to the Cloud SQL instance."
}

variable "network" {
  type    = string
  default = null
}

variable "backup_start_time" {
  type    = string
  default = "17:00"
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Specifies whether point-in-time recovery is enabled."
  default     = true
}

variable "transaction_log_retention_days" {
  type    = number
  default = 1
}

variable "maintenance_window_day" {
  type        = number
  default     = 5
  description = "Day of week of the one-hour maintenance window (1-7, starting on Monday), in UTC time"
}

variable "maintenance_window_hour" {
  type        = number
  default     = 20
  description = "Day of week of the one-hour maintenance window (0-23), in UTC time"
}

variable "enable_iam_authentication" {
  type    = bool
  default = false
}

# Cloud SQL for PostgreSQL specific flags

variable "logical_decoding" {
  type    = string
  default = "on"
}

variable "enable_query_insights" {
  type    = bool
  default = false
}

variable "query_insights_query_string_length" {
  type    = number
  default = 1024
}

variable "query_insights_record_application_tags" {
  type    = bool
  default = true
}

variable "query_insights_record_client_address" {
  type    = bool
  default = false
}

variable "backup_enabled" {
  type        = bool
  description = "Status backup is enabled or not."
  default     = true
}
variable "availability_type" {
  type        = string
  description = "availability type deploy"
  default     = null
  validation {
    condition     = var.availability_type == null ? true : contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability type must be in (ZONAL or REGIONAL), or leave empty to set based on default value."
  }
}

variable "disk_autoresize_limit" {
  type        = number
  description = "The maximum size to which storage capacity can be automatically increased"
  default     = 0
}

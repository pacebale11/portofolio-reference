locals {
  networks = {
    "staging"    = "projects/host-infra-staging/global/networks/vpc-host-staging"
    "production" = "projects/host-infra-production/global/networks/vpc-host-production"
  }

  # If var.network is defined, then we use it as the network to be used by the
  # Cloud SQL instance. However, the default is null, and we'll use the
  # predefined shared VPC for each environment.
  network = (
    var.network != null ? var.network : (
      lookup(local.networks, var.environment)
    )
  )

  availability_types = {
    "development" = "ZONAL"
    "staging"     = "ZONAL"
    "production"  = "REGIONAL"
  }

  database_flags = merge({
    slow_query_log                = "on"
    long_query_time               = "0.25"
    log_output                    = "FILE"
    "cloudsql_iam_authentication" = var.enable_iam_authentication ? "on" : "off"
    },
    var.additional_database_flags
  )

  default_label = {
    "env" = var.environment
  }

  tier = (
    var.tier != null ? var.tier : "db-custom-${var.cpu}-${var.memory}"
  )

  is_replica = var.master_instance_name != null

  availability_type = (
    local.is_replica ? "ZONAL" : lookup(local.availability_types, var.environment)
  )
}

resource "google_sql_database_instance" "cloudsql" {
  project             = var.project
  name                = var.instance_name
  database_version    = var.database_version
  region              = "asia-southeast2"
  deletion_protection = var.deletion_protection

  master_instance_name = var.master_instance_name

  settings {
    disk_size         = var.disk_size
    tier              = local.tier
    availability_type = local.availability_type
    disk_autoresize   = var.disk_autoresize
    activation_policy = var.activation_policy

    user_labels = merge(local.default_label, var.labels)

    ip_configuration {
      ipv4_enabled = var.public_ip

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        iterator = authnet

        content {
          name  = authnet.value.name
          value = authnet.value.value
        }
      }

      private_network = local.network

      enable_private_path_for_google_cloud_services = var.enable_private_path
    }

    # Backup configuration only needs to be defined for primary instances.
    dynamic "backup_configuration" {
      for_each = local.is_replica ? [] : [true]

      content {
        location                       = "asia-southeast2"
        enabled                        = true
        start_time                     = var.backup_start_time
        binary_log_enabled             = var.enable_point_in_time_recovery
        transaction_log_retention_days = var.transaction_log_retention_days
      }
    }

    dynamic "database_flags" {
      for_each = local.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    dynamic "maintenance_window" {
      for_each = !local.is_replica ? [true] : []

      content {
        day  = var.maintenance_window_day
        hour = var.maintenance_window_hour
      }
    }

    dynamic "insights_config" {
      for_each = var.enable_query_insights ? [true] : []

      content {
        query_insights_enabled  = true
        query_string_length     = var.query_insights_query_string_length
        record_application_tags = var.query_insights_record_application_tags
        record_client_address   = var.query_insights_record_client_address
      }
    }
  }

  # Ignore changes on settings["disk_size"] as we set
  # settings["disk_autoresize"] to true and the disk size will be increased
  # outside of Terraform.
  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }
}

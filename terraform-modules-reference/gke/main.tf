data "google_project" "project" {}

data "google_bigquery_dataset" "dataset_gke_usage" {
  count = var.enable_resource_usage_export ? 1 : 0

  dataset_id = "gke_usage"
  project    = data.google_project.project.project_id
}

data "google_pubsub_topic" "pubsub_gke_notification" {
  count = var.enable_notification_config ? 1 : 0

  name    = "gke-upgrade-events"
  project = data.google_project.project.project_id
}

resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = var.name
  location = "asia-southeast2"

  resource_labels = var.labels

  min_master_version = var.min_master_version

  networking_mode = "VPC_NATIVE"
  network         = var.network
  subnetwork      = var.subnetwork

  deletion_protection = var.deletion_protection

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = !var.enable_public_nodes
    enable_private_endpoint = !var.enable_master_public_endpoint
    master_ipv4_cidr_block  = var.enable_public_nodes ? null : var.master_ipv4_cidr_block

    master_global_access_config {
      enabled = false
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [true] : []

    content {
      dynamic "cidr_blocks" {
        for_each = toset(var.master_authorized_networks)

        content {
          cidr_block   = cidr_blocks.value.range
          display_name = cidr_blocks.value.name
        }
      }
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Configuration for temporary node pool, which will be deleted after cluster creation
  node_config {
    machine_type      = "e2-small"
    preemptible       = false
    disk_size_gb      = 10
    disk_type         = "pd-ssd"
    guest_accelerator = []
    image_type        = "cos_containerd"

    metadata = {
      "disable-legacy-endpoints" = "true"
    }

    service_account = length(var.node_pools) > 0 ? var.node_pools[0].service_account : "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_window_start_time
      end_time   = var.maintenance_window_end_time
      recurrence = var.maintenance_window_recurrence
    }

    dynamic "maintenance_exclusion" {
      for_each = toset(var.maintenance_exclusions)

      content {
        exclusion_name = maintenance_exclusion.value.name
        start_time     = maintenance_exclusion.value.start_time
        end_time       = maintenance_exclusion.value.end_time
      }
    }
  }

  release_channel {
    channel = "STABLE"
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = !var.enable_http_load_balancing
    }
    dns_cache_config {
      enabled = var.enable_dns_cache_config
    }
    network_policy_config {
      disabled = !var.enable_network_policy_addon
    }
    cloudrun_config {
      disabled = true
    }
    istio_config {
      disabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true # required since GKE 1.25 to use persistent disk
    }
    kalm_config {
      enabled = false
    }
    config_connector_config {
      enabled = false
    }
  }

  cluster_autoscaling {
    autoscaling_profile = var.cluster_autoscaling_profile

    # Despite being in `cluster_autoscaling` block, this argument actually
    # configures whether Node Auto-provisioning is enabled or not.
    enabled = false
  }

  database_encryption {
    state = "DECRYPTED"
  }

  default_snat_status {
    disabled = var.disable_default_snat
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  enable_intranode_visibility = var.enable_intranode_visibility
  enable_kubernetes_alpha     = false
  enable_l4_ilb_subsetting    = false
  enable_legacy_abac          = false
  enable_shielded_nodes       = var.enable_shielded_nodes
  enable_tpu                  = false

  network_policy {
    enabled  = var.enforce_network_policy
    provider = var.enforce_network_policy ? var.network_policy_provider : "PROVIDER_UNSPECIFIED"
  }

  monitoring_config {
    enable_components = var.monitoring_config_components

    managed_prometheus {
      enabled = var.enable_managed_prometheus
    }
  }

  logging_config {
    enable_components = var.logging_config_components
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  notification_config {
    pubsub {
      enabled = var.enable_notification_config
      topic   = var.enable_notification_config ? data.google_pubsub_topic.pubsub_gke_notification[0].id : null
    }
  }

  pod_security_policy_config {
    enabled = false
  }

  dynamic "authenticator_groups_config" {
    for_each = var.enable_gke_security_groups ? [true] : []

    content {
      security_group = "gke-security-groups@example.internal"
    }
  }

  dynamic "resource_usage_export_config" {
    for_each = var.enable_resource_usage_export ? [true] : []

    content {
      enable_network_egress_metering       = false
      enable_resource_consumption_metering = true
      bigquery_destination {
        dataset_id = data.google_bigquery_dataset.dataset_gke_usage[0].dataset_id
      }
    }
  }

  # Disable basic authentication by specifying `master_auth` block with no
  # `username` and `password` declared.
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  cost_management_config {
    enabled = var.enable_cost_allocation
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initial_node_count,
      node_config
    ]
  }
}

resource "google_container_node_pool" "pool" {
  provider = google-beta
  for_each = { for pool in var.node_pools : pool.name => pool }

  name     = each.value.name
  cluster  = google_container_cluster.cluster.name
  location = "asia-southeast2"

  version = each.value.version

  node_count = each.value.autoscaling_min_node_count != null && each.value.autoscaling_max_node_count != null ? null : each.value.node_count
  dynamic "autoscaling" {
    for_each = (
      (each.value.autoscaling_min_node_count != null && each.value.autoscaling_max_node_count != null)
      || (each.value.autoscaling_total_min_node_count != null && each.value.autoscaling_total_max_node_count != null)
    ) ? [true] : []

    content {
      total_min_node_count = each.value.autoscaling_total_min_node_count
      total_max_node_count = each.value.autoscaling_total_max_node_count
      min_node_count       = each.value.autoscaling_min_node_count
      max_node_count       = each.value.autoscaling_max_node_count
      location_policy      = each.value.autoscaling_location_policy
    }
  }

  # On creating the node pool, set `initial_node_count` to 1 or more to
  # "unstuck" the node pool. See https://stackoverflow.com/q/59192943/2301264
  # for context.
  initial_node_count = max(
    1,
    each.value.autoscaling_min_node_count != null ? each.value.autoscaling_min_node_count : 0,
    each.value.node_count != null ? each.value.node_count : 0,
    each.value.autoscaling_total_min_node_count != null ? each.value.autoscaling_total_min_node_count : 0,
  )

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  max_pods_per_node = each.value.max_pods_per_node

  node_config {
    machine_type      = each.value.machine_type
    preemptible       = each.value.preemptible
    disk_size_gb      = each.value.disk_size_gb
    disk_type         = each.value.disk_type
    guest_accelerator = []
    image_type        = each.value.image
    logging_variant   = each.value.logging_variant

    labels = each.value.labels
    tags   = each.value.tags == null ? [] : each.value.tags

    dynamic "taint" {
      for_each = each.value.taint == null ? [] : each.value.taint

      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    metadata = {
      "disable-legacy-endpoints" = "true"
    }

    service_account = each.value.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/userinfo.email",
    ]

    workload_metadata_config {
      mode = each.value.enable_workload_identity == null ? "GKE_METADATA" : (each.value.enable_workload_identity ? "GKE_METADATA" : "GCE_METADATA")
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }

    dynamic "linux_node_config" {
      for_each = each.value.sysctl_config != null ? [true] : []

      content {
        sysctls = each.value.sysctl_config
      }
    }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  depends_on = [
    google_container_cluster.cluster
  ]

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config[0].resource_labels,
      node_config[0].kubelet_config,
    ]
  }
}

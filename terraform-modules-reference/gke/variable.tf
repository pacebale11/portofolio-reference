variable "name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Kubernetes cluster labels"
}

variable "network" {
  type        = string
  description = "VPC network for the cluster"
}

variable "subnetwork" {
  type        = string
  description = "VPC subnet for the cluster"
}

variable "pods_secondary_range_name" {
  type    = string
  default = "pods"
}

variable "services_secondary_range_name" {
  type    = string
  default = "services"
}

variable "min_master_version" {
  type    = string
  default = null
}

variable "enable_master_public_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  type = string
}

variable "master_authorized_networks" {
  type = list(object({
    name  = optional(string)
    range = string
  }))
  default = []
}

variable "maintenance_window_start_time" {
  type = string
}

variable "maintenance_window_end_time" {
  type = string
}

variable "maintenance_window_recurrence" {
  type = string
}

variable "maintenance_exclusions" {
  type = list(object({
    name       = string
    start_time = string
    end_time   = string
  }))
  default = []
}

variable "monitoring_config_components" {
  type    = list(string)
  default = ["SYSTEM_COMPONENTS"]
}

variable "logging_config_components" {
  type    = list(string)
  default = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

variable "cluster_autoscaling_profile" {
  type    = string
  default = "BALANCED"
}

variable "node_pools" {
  type = list(object({
    name                             = string
    version                          = string
    node_count                       = optional(number)
    machine_type                     = string
    disk_size_gb                     = number
    disk_type                        = string
    image                            = string
    labels                           = map(string)
    tags                             = optional(list(string))
    taint                            = optional(list(map(string)))
    service_account                  = string
    preemptible                      = bool
    max_pods_per_node                = optional(number, 110)
    autoscaling_location_policy      = optional(string)
    autoscaling_total_min_node_count = optional(number)
    autoscaling_total_max_node_count = optional(number)
    autoscaling_min_node_count       = optional(number)
    autoscaling_max_node_count       = optional(number)
    enable_workload_identity         = optional(bool)
    logging_variant                  = optional(string)
    sysctl_config                    = optional(map(string))
  }))
}

variable "enable_cost_allocation" {
  type    = bool
  default = true
}

variable "enable_dns_cache_config" {
  type    = bool
  default = true
}

variable "enable_gke_security_groups" {
  type    = bool
  default = true
}

variable "enable_http_load_balancing" {
  type    = bool
  default = true
}

variable "enable_intranode_visibility" {
  type    = bool
  default = true
}

variable "enable_managed_prometheus" {
  type    = bool
  default = false
}

variable "enable_network_policy_addon" {
  type    = bool
  default = true
}

variable "enforce_network_policy" {
  type    = bool
  default = true
}

variable "network_policy_provider" {
  type    = string
  default = "CALICO"
}

variable "enable_public_nodes" {
  type    = bool
  default = false
}

variable "enable_shielded_nodes" {
  type    = bool
  default = false
}

variable "disable_default_snat" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "enable_notification_config" {
  type    = bool
  default = true
}

variable "enable_resource_usage_export" {
  type    = bool
  default = true
}

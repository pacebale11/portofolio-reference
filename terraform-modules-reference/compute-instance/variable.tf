variable "name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "network" {
  type    = string
  default = null
}

variable "subnetwork" {
  type    = string
  default = null
}

variable "zone" {
  type = string

  validation {
    condition     = contains(["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"], var.zone)
    error_message = "Valid values for var: zone are (asia-southeast2-a, asia-southeast2-b, asia-southeast2-c)."
  }
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "disk_image" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "disk_labels" {
  type    = map(string)
  default = {}
}

variable "service_account" {
  type = string
}

variable "scopes" {
  type    = list(string)
  default = []
}

variable "can_ip_forward" {
  type    = bool
  default = false
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "is_public" {
  type    = bool
  default = false
}

variable "public_ip_address" {
  type    = string
  default = ""
}

variable "attached_disk" {
  type = list(object({
    device_name = string
    source      = string
    # (Optional) Either "READ_ONLY" or "READ_WRITE", defaults to "READ_WRITE"
    mode = optional(string)
  }))
  default     = []
  description = "List of disk to be attach"
}

variable "allow_stopping_for_update" {
  type    = bool
  default = true
}

variable "resource_policies" {
  type    = list(string)
  default = []
}

variable "metadata_startup_script" {
  type    = string
  default = null
}

variable "additional_network_interfaces" {
  description = "Additional network interface"
  type = list(object({
    network_id    = string
    subnetwork_id = string
    network_ip    = optional(string)
  }))
  default = []
}

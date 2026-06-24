locals {
  metadata = {
    "enable-oslogin"         = "true"
    "block-project-ssh-keys" = "true"
  }
}

resource "google_compute_instance" "compute" {
  name                      = var.name
  machine_type              = var.machine_type
  zone                      = var.zone
  project                   = var.project
  deletion_protection       = var.deletion_protection
  allow_stopping_for_update = var.allow_stopping_for_update
  can_ip_forward            = var.can_ip_forward
  resource_policies         = var.resource_policies

  labels = var.labels
  tags   = var.tags

  boot_disk {
    initialize_params {
      image  = var.disk_image
      size   = var.disk_size
      type   = var.disk_type
      labels = var.disk_labels
    }
  }

  dynamic "attached_disk" {
    for_each = var.attached_disk
    iterator = attacheddisk

    content {
      device_name = attacheddisk.value.device_name
      source      = attacheddisk.value.source
      mode        = attacheddisk.value.mode
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.is_public ? [true] : []

      content {
        nat_ip = var.public_ip_address
      }
    }
  }

  dynamic "network_interface" {
    for_each = var.additional_network_interfaces
    content {
      network    = network_interface.value.network_id
      subnetwork = network_interface.value.subnetwork_id
      network_ip = network_interface.value.network_ip
    }
  }

  metadata_startup_script = var.metadata_startup_script

  metadata = merge(var.metadata, local.metadata)

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }
}
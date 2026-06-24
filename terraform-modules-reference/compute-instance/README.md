# [Compute Instance](https://cloud.google.com/compute/docs/instances)

This Terraform module configures our Compute Instance according to our standard:

* Location: GCP Jakarta region
* OS-login enabled
* Project SSH keys is disabled
* Enforce usage of user-defined service account instead of default service account

## Creating new Compute Instance

This guide assumes you are familiar with `git`, including pushing your changes into a non-`master` branch, and submitting a merge request.

1. On your project directory, create a file named `compute.tf`, and fill it based on this template:
    ```terraform
    module "vm_testing" {
      source = "git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//compute-instance?ref=compute-instance/1.0.0"

      project = module.project.project_id
      environment = "production"

      name = "vm-testing"
      machine_type = "e2-medium"
      zone = "asia-southeast2-a"

      labels = {
        env     = "production"
        purpose = "vm-testing"
      }

      disk_image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
      disk_size  = 40
      disk_type  = "pd-balanced"
      disk_labels = {
        "key" = "value"
      }

      service_account = google_service_account.vm_testing.email
      scopes = ["cloud-platform"]
    }
    ```

    For elasticsearch VM, an attached disk is required. Declare `google_compute_disk` and add it to `attached_disk`.
    ```
    resource "google_compute_disk" "testing-elasticsearch-1-1" {
      name    = "testing-elasticsearch-1-1"
      type    = "pd-ssd"
      zone    = "asia-southeast2-a"
      project = module.project.project_id
      size    = 32
    }

    module "vm_testing" {
        attached_disk = [
          {
            device_name = "persistent-disk-1"
            mode        = "READ_WRITE"
            source      = google_compute_disk.testing-elasticsearch-1-1.self_link
          }
        ]
    }
    ```
2. Commit, then push your changes to a new branch and create a new MR.
3. Follow the merge request workflow described in this page: https://docs.google.com/document/d/1fgMUkL0lNB7L1o4Uypui_Az6LApkpN3FCx6CbSlAhuk/edit?usp=drive_link to get your MR merged.

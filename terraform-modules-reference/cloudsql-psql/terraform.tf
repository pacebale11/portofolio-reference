terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # Require provider version 4.0.0 or higher.
      version = ">= 4.0.0"
    }
  }

  # Require Terraform version 1.0.2 at minimum.
  required_version = ">= 1.0.2"
}

terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"

      # Require provider version 5.0.0 or higher.
      version = ">= 5.0.0"
    }
  }

  # Require Terraform version 1.3.0 at minimum.
  required_version = ">= 1.3.0"
}

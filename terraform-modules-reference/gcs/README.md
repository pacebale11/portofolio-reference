# [Cloud Storage buckets](https://cloud.google.com/storage/docs)

This Terraform module configures our Cloud Storage buckets according to our standard:

* Location: GCP Jakarta region (`asia-southeast2`)
* [Uniform bucket-level access enabled](https://cloud.google.com/storage/docs/uniform-bucket-level-access)

## Creating new Cloud Storage buckets

This guide assumes you are familiar with `git`, including pushing your changes into a non-`master` branch, and submitting a merge request.

1. On your project directory, create a file named `gcs.tf`, and fill it based on this template:
    ```terraform
    module "gcs_<bucket name>" {
      source = "git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//gcs?ref=gcs/1.0.0"

      name    = "<bucket name>"
      project = module.project.project_id

      policy = {}
      # Grant policy to the bucket by following this format.
      # 
      # policy = {
      #   "group:gcp-some-group@example.internal" = [  # must be a group, not individual users
      #     "roles/storage.legacyBucketOwner" # see https://cloud.google.com/storage/docs/access-control/iam-roles.
      #   ],
      #
      #   Optionally, grant public access to this bucket.
      #
      #   "allUsers" = [
      #     "roles/storage.legacyBucketReader"
      #   ]
      # }

      # Optionally, set lifecycle rules.
      # See https://cloud.google.com/storage/docs/managing-lifecycles.
      #
      # lifecycle_rules = [
      #   {
      #     action = {
      #       type = "Delete"
      #     },
      #     condition = {
      #       age = 15
      #     }
      #   }
      # ]
    }
    ```
1. Commit, then push your changes to a new branch and create a new MR.
1. Follow the merge request workflow described in this page: https://docs.google.com/document/d/1fgMUkL0lNB7L1o4Uypui_Az6LApkpN3FCx6CbSlAhuk/edit?usp=drive_link to get your MR merged.

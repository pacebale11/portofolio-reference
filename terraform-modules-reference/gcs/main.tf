resource "google_storage_bucket" "bucket" {
  name          = var.name
  project       = var.project
  location      = var.location
  labels        = var.labels
  storage_class = var.storage_class
  force_destroy = var.force_destroy

  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }

      condition {
        age                        = lifecycle_rule.value.condition.age
        created_before             = lifecycle_rule.value.condition.created_before
        custom_time_before         = lifecycle_rule.value.condition.custom_time_before
        days_since_custom_time     = lifecycle_rule.value.condition.days_since_custom_time
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class
        noncurrent_time_before     = lifecycle_rule.value.condition.noncurrent_time_before
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        with_state                 = lifecycle_rule.value.condition.with_state
      }
    }
  }

  versioning {
    enabled = var.enable_versioning
  }

  dynamic "cors" {
    for_each = (var.cors_method == null && var.cors_origin == null && var.cors_response_header == null) ? [] : [true]

    content {
      method          = var.cors_method
      origin          = var.cors_origin
      response_header = var.cors_response_header
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_period > 0 ? [true] : []

    content {
      is_locked        = var.lock_retention_period
      retention_period = var.retention_period
    }
  }

  dynamic "website" {
    for_each = (var.website_main_page_suffix != null || var.website_not_found_page != null) ? [true] : []

    content {
      main_page_suffix = var.website_main_page_suffix
      not_found_page   = var.website_not_found_page
    }
  }
}

data "google_iam_policy" "bucket" {
  dynamic "binding" {
    for_each = transpose(var.policy)

    content {
      role    = binding.key
      members = binding.value
    }
  }

  dynamic "binding" {
    for_each = flatten([
      for p in var.condition_policy :
      [
        for r in p.roles : {
          members   = p.members
          role      = r
          condition = p.condition
        }
      ]
    ])

    content {
      members = binding.value.members
      role    = binding.value.role

      condition {
        title       = try(binding.value.condition.title, null)
        description = try(binding.value.condition.description, null)
        expression  = try(binding.value.condition.expression, null)
      }
    }
  }
}

resource "google_storage_bucket_iam_policy" "bucket" {
  bucket      = google_storage_bucket.bucket.name
  policy_data = data.google_iam_policy.bucket.policy_data

  # Ensure the IAM policy is applied after its bucket is created.
  depends_on = [
    google_storage_bucket.bucket
  ]
}
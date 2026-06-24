variable "name" {
  type        = string
  description = "Bucket name"
}

variable "project" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "force_destroy" {
  type        = bool
  description = "Allow delete a bucket that contains objects or not"
  default     = true
}

variable "location" {
  type    = string
  default = "asia-southeast2"
}

variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}

variable "policy" {
  type    = map(list(string))
  default = {}
}

variable "condition_policy" {
  type = list(object({
    members   = list(string)
    roles     = list(string)
    condition = map(string)
  }))
  default = []
}


variable "lifecycle_rules" {
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      custom_time_before         = optional(string)
      days_since_custom_time     = optional(number)
      days_since_noncurrent_time = optional(number)
      matches_storage_class      = optional(list(string))
      noncurrent_time_before     = optional(string)
      num_newer_versions         = optional(number)
      with_state                 = optional(string)
    })
  }))
  default = []
}

variable "enable_versioning" {
  type    = bool
  default = false
}

variable "cors_method" {
  type    = list(string)
  default = null
}

variable "cors_origin" {
  type    = list(string)
  default = null
}

variable "cors_response_header" {
  type    = list(string)
  default = null
}

variable "cors_max_age_seconds" {
  type    = number
  default = null
}

variable "retention_period" {
  type    = number
  default = 0
}

variable "lock_retention_period" {
  type    = bool
  default = false
}

variable "website_main_page_suffix" {
  type    = string
  default = null
}

variable "website_not_found_page" {
  type    = string
  default = null
}

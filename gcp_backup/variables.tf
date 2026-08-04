variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "shopeasy"
}

variable "gcp_region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "bucket_suffix" {
  description = "Unique bucket suffix"
  type        = string
}
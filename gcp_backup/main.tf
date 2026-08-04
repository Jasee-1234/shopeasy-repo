# =============================================================================
# GCS Bucket - Backup target for AWS S3 assets
# =============================================================================
resource "google_storage_bucket" "assets_backup" {
  name          = "${var.project_name}-assets-backup-${var.bucket_suffix}"
  location      = var.gcp_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = "dev"
    purpose     = "aws-s3-backup"
    project     = var.project_name
  }
}

# =============================================================================
# Service Account - used to authenticate the AWS -> GCS sync process
# =============================================================================
resource "google_service_account" "backup_sync" {
  account_id   = "${var.project_name}-backup-sync"
  display_name = "ShopEasy AWS-to-GCS Backup Sync"
  description  = "Service account used to sync AWS S3 assets to GCS backup bucket"
}

resource "google_storage_bucket_iam_member" "backup_sync_writer" {
  bucket = google_storage_bucket.assets_backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backup_sync.email}"
}

resource "google_service_account_key" "backup_sync_key" {
  service_account_id = google_service_account.backup_sync.name
}
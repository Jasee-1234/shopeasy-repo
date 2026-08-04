output "backup_bucket" {
  value = google_storage_bucket.assets_backup.name
}

output "backup_service_account" {
  value = google_service_account.backup_sync.email
}
output "name" {
  value = google_sql_database_instance.cloudsql.name
}

output "service_account_email_address" {
  value = google_sql_database_instance.cloudsql.service_account_email_address
}

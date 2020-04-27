output "db_password" {
  value       = module.db.this_db_instance_password
  description = "The password for logging in to the database."
  sensitive   = true
}

output "db_instance_address" {
  value       = module.db.this_db_instance_address
  description = "DB instance address"
}

output "db_instance_endpoint" {
  value       = module.db.this_db_instance_endpoint
  description = "DB instance endpoint"
}

output "db_instance_username" {
  value       = module.db.this_db_instance_username
  description = "DB instance username"
}

output "security_group_id" {
  value       = aws_security_group.db_allow_all.id
  description = "Security group id used by the Postgres Instance"
}
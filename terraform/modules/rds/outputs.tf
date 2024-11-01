output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = try(aws_db_instance.this.id, null)
}

output "rds_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(aws_db_instance.this.arn, null)
}

output "rds_instance_address" {
  description = "The address of the RDS instance"
  value       = try(aws_db_instance.this.address, null)
}

output "rds_instance_port" {
  description = "The port of the RDS instance"
  value       = try(aws_db_instance.this.port, null)
}

output "random_password" {
  description = "The randomly generated password for the RDS instance"
  value       = random_password.password.result
}

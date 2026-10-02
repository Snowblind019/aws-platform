output "organization_id" {
  description = "ID of the organization. Log paths in the CloudTrail bucket start with it."
  value       = aws_organizations_organization.this.id
}

output "lab_account_id" {
  description = "Account ID of the lab member account."
  value       = aws_organizations_account.lab.id
}

output "allowed_regions" {
  description = "Regions the lab account may use; later stacks read this through terraform_remote_state."
  value       = var.allowed_regions
}

output "trail_bucket_name" {
  description = "S3 bucket holding the organization CloudTrail logs."
  value = aws_s3_bucket.trail_logs.id
}
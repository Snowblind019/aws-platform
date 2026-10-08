output "allowed_regions" {
    description = "Regions the lab account may use, passthrough from the org stack; later stacks read this."
    value = local.allowed_regions
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider in lab. Project 3's deploy roles trust it."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "lab_account_id" {
  description = "ID of the lab account, where this stack runs."
  value       = data.aws_caller_identity.current.account_id
}
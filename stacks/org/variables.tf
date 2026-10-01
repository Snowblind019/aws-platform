variable "mgmt_profile" {
  type        = string
  description = "AWS CLI profile the provider uses; must point at the management account."
  default     = "mgmt-admin"
}

variable "lab_account_email" {
  type        = string
  description = "Email on the lab account; must match Organizations exactly. Set in terraform.tfvars, never in code."
  sensitive   = true
}
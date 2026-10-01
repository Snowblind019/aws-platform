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

variable "allowed_regions" {
  type        = list(string)
  description = "Regions the lab account may use; feeds the region-lock SCP and later stacks."
  default     = ["us-west-2", "us-east-1"]

  validation {
    condition     = contains(var.allowed_regions, "us-west-2")
    error_message = "allowed_regions must include us-west-2. The state bucket and Identity Center live there."
  }
}
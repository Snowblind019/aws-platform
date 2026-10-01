variable "mgmt_profile" {
  type        = string
  description = "AWS CLI profile the provider uses; must point at the management account."
  default     = "mgmt-admin"
}
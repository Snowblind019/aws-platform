output "tags" {
  description = "Standard tags for every resource in a stack."
  value = {
    Project   = var.project
    ManagedBy = "terraform"
    Owner     = var.owner
    Ephemeral = tostring(var.ephemeral)
  }
}
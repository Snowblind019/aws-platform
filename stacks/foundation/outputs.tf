output "allowed_regions" {
    description = "Regions the lab account may use, passthrough from the org stack; later stacks read this."
    value = local.allowed_regions
}
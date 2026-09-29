module "tags" {
    source = "../modules/tags"

    project = "bootstrap"
    ephemeral = false  
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "snowblind019"
}
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = module.tags.tags
  }
}
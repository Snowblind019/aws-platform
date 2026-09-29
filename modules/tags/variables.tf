terraform {
    required_providers {
      
      aws = {
        source = "hashicorp/aws"
      }
    }
}

provider "aws" {
    region = "us-west-2"
  
}

variable "project" {
    type = string
    description = "Name of the stack; becomes the Project tag."

    validation {
      condition = can(regex("^[a-z0-9-]+$", var.project))
      error_message = "project must use only lowercase letters, digits, and hypens."
    }
}

variable "ephemeral" {
    type = bool
    description = "Whether this stack is meant to be torn down after use; become the Ephemeral tag."  
}

variable "owner" {
    type = string
    description = "Who owns the resources; becomes the Owner tag."
    default = "Snowblind019"
  
}
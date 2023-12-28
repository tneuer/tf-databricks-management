# TAGS

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], lower(var.environment))
    error_message = "Unsupported environement specified. Supported regions include: dev, prod"
  }
  default = "dev"
}

variable "location" {
  type        = string
  description = "The Azure Region to deploy resources."

  validation {
    condition     = can(regex("^switzerland", var.location))
    error_message = "Unsupported Azure Region specified. Only Switzerland Regions are supported."
  }
}

variable "project" {
  type = string
}

# AZURE 

variable "rg_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

# DB WORKSPACE

variable "db_storage_account_name" {
  type = string
}

data "azurerm_client_config" "current" {}

locals {
  tags = {
    environment = var.environment
    project     = var.project
    source      = "terraform"
  }
}

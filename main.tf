terraform {
  required_version = ">= 1.6.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

module "db_management" {
  source                            = "./modules/db_management"
  rg_name                           = var.rg_name
  location                          = var.location
  project                           = var.project
  db_storage_account_name           = data.azurerm_storage_account.db_metastore.name
  key_vault_id                      = data.azurerm_key_vault.tfstatekv.id
  db_workspace_id                   = data.azurerm_databricks_workspace.db_workspace1.workspace_id
  db_metastore_storage_account_name = data.azurerm_storage_account.db_metastore.name
  db_metastore_container_name       = data.azurerm_storage_container.db_metastore.name
  db_host_name                      = data.azurerm_key_vault_secret.db_host_name.value
  tags                              = local.tags
}

output "db_workspace" {
  value = module.db_management
}

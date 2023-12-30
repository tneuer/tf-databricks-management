data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_databricks_workspace" "db_workspace1" {
  name                = var.db_workspace_name
  resource_group_name = var.rg_name
}

data "azurerm_storage_account" "db_metastore" {
  name                = var.db_storage_account_name
  resource_group_name = var.rg_name
}

data "azurerm_storage_container" "db_metastore" {
  name                 = var.db_metastore_container_name
  storage_account_name = data.azurerm_storage_account.db_metastore.name
}

data "azurerm_key_vault" "tfstatekv" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "db_host_name" {
  name         = "DBHostname"
  key_vault_id = data.azurerm_key_vault.tfstatekv.id
}
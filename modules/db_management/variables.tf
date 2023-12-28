variable "location" {
  type = string
}

variable "project" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "db_storage_account_name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "db_workspace_id" {
  type = string
}

variable "db_metastore_storage_account_name" {
  type = string
}

variable "db_metastore_container_name" {
  type = string
}

variable "db_host_name" {
  type = string
}

variable "tags" {
  type = map(any)
}

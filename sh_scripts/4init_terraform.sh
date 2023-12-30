#!/usr/bin/env bash
source ./sh_scripts/variables.sh $1

# Initialize Terraform backend configs
echo resource_group_name  = \"$TF_RESOURCE_GROUP_NAME\" > ./configs/config$ENV_SUFFIX4.azure.tfbackend
echo storage_account_name  = \"$TF_STORAGE_ACCOUNT_NAME\" >> ./configs/config$ENV_SUFFIX4.azure.tfbackend
echo container_name  = \"$TF_CONTAINER_NAME\" >> ./configs/config$ENV_SUFFIX4.azure.tfbackend
echo key  = \"$TF_FILE_NAME\" >> ./configs/config$ENV_SUFFIX4.azure.tfbackend

# Initialize Terraform variables
echo location = \"$LOCATION\" > ./terraform.tfvars
echo project = \"$PROJECT_NAME\" >> ./terraform.tfvars
echo key_vault_name = \"$TF_KEYVAULT_NAME\" >> ./terraform.tfvars
echo rg_name = \"$TF_RESOURCE_GROUP_NAME\" >> ./terraform.tfvars
echo db_workspace_name = \"$DATABRICKS_WORKSPACE_NAME\" >> ./terraform.tfvars
echo db_storage_account_name = \"$DATABRICKS_METASTORE_STORAGE_ACCOUNT_NAME\" >> ./terraform.tfvars
echo db_metastore_container_name = \"$DATABRICKS_METASTORE_CONTAINER_NAME\" >> ./terraform.tfvars
echo >> ./terraform.tfvars

terraform init -backend-config="./configs/config_dev.azure.tfbackend";

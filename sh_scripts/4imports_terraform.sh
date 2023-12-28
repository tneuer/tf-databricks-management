#!/usr/bin/env bash
source ./sh_scripts/variables.sh
export ARM_ACCESS_KEY=$(az keyvault secret show --name $TF_SECRET_NAME --vault-name $TF_KEYVAULT_NAME --query value -o tsv);

echo resource_group_name  = \"$TF_RESOURCE_GROUP_NAME\" > ./configs/config_dev.azure.tfbackend
echo storage_account_name  = \"$TF_STORAGE_ACCOUNT_NAME\" >> ./configs/config_dev.azure.tfbackend
echo container_name  = \"$TF_CONTAINER_NAME\" >> ./configs/config_dev.azure.tfbackend
echo key  = \"$TF_FILE_NAME\" >> ./configs/config_dev.azure.tfbackend
terraform init -backend-config="./configs/config_dev.azure.tfbackend";

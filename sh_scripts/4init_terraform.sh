#!/usr/bin/env bash
source ./sh_scripts/variables.sh $1

echo resource_group_name  = \"$TF_RESOURCE_GROUP_NAME\" > ./configs/config_dev.azure.tfbackend
echo storage_account_name  = \"$TF_STORAGE_ACCOUNT_NAME\" >> ./configs/config_dev.azure.tfbackend
echo container_name  = \"$TF_CONTAINER_NAME\" >> ./configs/config_dev.azure.tfbackend
echo key  = \"$TF_FILE_NAME\" >> ./configs/config_dev.azure.tfbackend
terraform init -backend-config="./configs/config_dev.azure.tfbackend";

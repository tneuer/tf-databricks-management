#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Needed one of [dev, prod]."
    exit 1
fi

if [ $1 = "dev" ]
then
    ENV_SUFFIX1="Dev"
    ENV_SUFFIX2="dev"
    ENV_SUFFIX3="-dev"
    ENV_SUFFIX4="_dev"
elif [ $1 = "prod" ]
then
    ENV_SUFFIX1=""
    ENV_SUFFIX2=""
    ENV_SUFFIX3=""
    ENV_SUFFIX4=""
else
    echo "Parameter must be one of [dev, prod]."
    exit 1
fi

# General
TENANT_ID=$(az account show | jq -r ".tenantId")
SUBSCRIPTION_ID=$(az account show --query id --output tsv);
LOCATION="switzerlandnorth"
GIT_ROOT="tneuer"
TF_REPO=$(basename `git rev-parse --show-toplevel`)
PROJECT_NAME="test-project"$ENV_SUFFIX3

# Build RG
BUILD_RESOURCE_GROUP_NAME_RESOURCES="terraform-databricks-rg"$ENV_SUFFIX3

# Terraform state backend RG
TF_RESOURCE_GROUP_NAME="terraform-databricks-rg"$ENV_SUFFIX3
TF_STORAGE_ACCOUNT_NAME="tfstatefilestoragetn"$ENV_SUFFIX2
TF_CONTAINER_NAME="tfstatefiledbmanagement"$ENV_SUFFIX2
TF_KEYVAULT_NAME="$PROJECT_NAME-kv"
TF_FILE_NAME="db_management$ENV_SUFFIX4.tfstate"
TF_SECRET_NAME="dbManagementTfstatesecret"$ENV_SUFFIX1

# Networking
PROJECT_CIDR_RANGE="10.0.0.0/26"

# Github
GITHUB_TF_SP_NAME="TerraformDevOpsGithubAction"$ENV_SUFFIX1
GITHUB_OICD_CREDENTIALS_NAME="Github_OICD_credentials_main"

# Databricks
DATABRICKS_TF_SP_NAME="DatabricksDevOpsGithubAction"$ENV_SUFFIX1
DATABRICKS_METASTORE_STORAGE_ACCOUNT_NAME="dbstoragetn"$ENV_SUFFIX2
DATABRICKS_WORKSPACE_NAME="db-workspace-$PROJECT_NAME"

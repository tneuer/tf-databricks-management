#!/usr/bin/env bash
source ./sh_scripts/variables.sh

DB_HOST_NAME=$(az keyvault secret show --name DBHostname --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
WORKSPACE_TOKEN_ENDPOINT="$DB_HOST_NAME/oidc/v1/token"
CLIENT_SECRET=$(az keyvault secret show --name $DATABRICKS_TF_SP_NAME'Secret' --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
CLIENT_ID=$(az keyvault secret show --name $DATABRICKS_TF_SP_NAME'AppID' --vault-name $TF_KEYVAULT_NAME --query value -o tsv)

RESPONSE=$(curl --request POST --url $WORKSPACE_TOKEN_ENDPOINT -u "$CLIENT_ID:$CLIENT_SECRET" --data 'grant_type=client_credentials&scope=all-apis')
OAUTH_TOKEN=$(echo $RESPONSE | jq '.access_token' | tr -d '"')
az keyvault secret set --name $DATABRICKS_TF_SP_NAME'OauthToken' --vault-name $TF_KEYVAULT_NAME --value $OAUTH_TOKEN

# echo "Configuring databrick-cli authentication"
# declare dbconfig=$(<~/.databrickscfg)
# if [[ $dbconfig = *"host = "* && $dbconfig = *"token = "* ]]; then
#     echo "file [~/.databrickscfg] is already configured"
# else
#     echo "Populating [~/.databrickscfg]"
#     > ~/.databrickscfg
#     echo "[DEFAULT]" >> ~/.databrickscfg
#     echo "host = $DB_HOST_NAME" >> ~/.databrickscfg
#     echo "token = $OAUTH_TOKEN" >> ~/.databrickscfg
#     echo "" >> ~/.databrickscfg
# fi

echo "Configuring databrick-cli authentication"
echo "Populating [~/.databrickscfg]"
> ~/.databrickscfg
echo "[DEFAULT]" >> ~/.databrickscfg
echo "host = $DB_HOST_NAME" >> ~/.databrickscfg
echo "token = $OAUTH_TOKEN" >> ~/.databrickscfg
echo "" >> ~/.databrickscfg

#!/usr/bin/env bash
# Can not be run as part of CI/CD pipeline because this script must be run with priviliges to create the SP and give it the necessary roles.
# Should be run once in order to enable the automatic pipeline runs via Github actions or other CI/CD service providers.
source ./sh_scripts/variables.sh $1

echo Creating service principal $DATABRICKS_TF_SP_NAME...
RESPONSE=$(az ad sp create-for-rbac --name $DATABRICKS_TF_SP_NAME --role reader --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TF_RESOURCE_GROUP_NAME)
APP_ID=$(echo $RESPONSE | jq '.appId' | tr -d '"')
PASSWORD=$(echo $RESPONSE | jq '.password' | tr -d '"')
az keyvault secret set --name $DATABRICKS_TF_SP_NAME'AppID' --vault-name $TF_KEYVAULT_NAME --value $APP_ID
az keyvault secret set --name $DATABRICKS_TF_SP_NAME'Password' --vault-name $TF_KEYVAULT_NAME --value $PASSWORD
az ad app federated-credential create --id  $APP_ID --parameters ./configs/github_oicd_credential.json

# Role assignments
echo Configure Service Principal role assignments
az role assignment create --assignee  $APP_ID --role "Storage Account Key Operator Service Role" --subscription $SUBSCRIPTION_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TF_RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$DATABRICKS_METASTORE_STORAGE_ACCOUNT_NAME
az role assignment create --assignee  $APP_ID --role "Storage Account Key Operator Service Role" --subscription $SUBSCRIPTION_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TF_RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$TF_STORAGE_ACCOUNT_NAME
az keyvault set-policy --name $TF_KEYVAULT_NAME --spn $APP_ID --secret-permissions get # set list

# Add Service Principal to Databricks workspace
echo Add Service Principal to Databricks workspace
DB_HOSTNAME=$(az keyvault secret show --name DBHostname --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
DB_PERSONAL_TOKEN=$(az keyvault secret show --name DBPersonalToken --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
PAYLOAD=$'{
    "schemas": [
        "urn:ietf:params:scim:schemas:core:2.0:ServicePrincipal"
    ],
    "applicationId": "'$APP_ID'",
    "displayName": "'$DATABRICKS_TF_SP_NAME'",
    "entitlements": [
        {"value": "workspace-access"},
        {"value": "allow-cluster-create"}
    ],
    "active": true
}'
RESPONSE=$(curl -X POST --header 'content-type:application/json' --header "authorization:Bearer $DB_PERSONAL_TOKEN" -d "$PAYLOAD" $DB_HOSTNAME/api/2.0/preview/scim/v2/ServicePrincipals)
DATABRICKS_SP_ID=$(echo $RESPONSE | jq '.id' | tr -d '"')
az keyvault secret set --name $DATABRICKS_TF_SP_NAME'ID' --vault-name $TF_KEYVAULT_NAME --value $DATABRICKS_SP_ID

# Save credentials to Github
echo Setting Github secrets...
gh secret set DATABRICKS_CLIENT_ID --body ${APP_ID} --repos $GIT_ROOT/$TF_REPO;
gh secret set DATABRICKS_TENANT_ID --body ${TENANT_ID} --repos $GIT_ROOT/$TF_REPO;
gh secret set DATABRICKS_SUBSCRIPTION_ID --body ${SUBSCRIPTION_ID} --repos $GIT_ROOT/$TF_REPO;
gh secret set DATABRICKS_HOST --body ${DB_HOSTNAME} --repos $GIT_ROOT/$TF_REPO;

# Steps needed to be done manually
echo
echo Go to Databricks Account page under "User Management > Service Principals > $DATABRICKS_TF_SP_NAME"  and generate an OAUTH secret. This source  should be stored in the keyvault under $DATABRICKS_TF_SP_NAME'Secret'
echo 'Use >> az keyvault secret set --name $DATABRICKS_TF_SP_NAME'"'Secret'"' --vault-name $TF_KEYVAULT_NAME --value <SECRET>'
echo 
echo Put the Databricks account ID in the key vault as well.
echo 'Use >> az keyvault secret set --name DBAccountID --vault-name $TF_KEYVAULT_NAME --value <ACCOUNT_ID>'

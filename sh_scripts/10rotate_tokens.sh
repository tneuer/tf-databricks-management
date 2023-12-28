# This script automatically rotates the DB Access Token. Meant to be run every 24 hours. Creates a new token valid for 25 hours.
# Initially create a Databricks Token manually (e.g. <TokenName>) and store it with the same secret name (<TokenName>) in the Azure key vault
# Fetch the Token ID via   >> curl -X GET --header 'content-type:application/json' --header "authorization:Bearer $<TokenValue>" -d '{}' $DB_HOSTNAME/api/2.0/token/list
# Save the Token ID in the key vault with secret name "<TokenName>ID"
# Ready to use this script with input parameter <TokenName>

source ./sh_scripts/variables.sh

# Fetch current token values
DB_HOSTNAME=$(az keyvault secret show --name DBHostname --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
DB_TOKEN=$(az keyvault secret show --name $1 --vault-name $TF_KEYVAULT_NAME --query value -o tsv)
DB_TOKEN_ID=$(az keyvault secret show --name "$1"ID --vault-name $TF_KEYVAULT_NAME --query value -o tsv)

# Create temporary token
TEMP_RESPONSE=$(curl -X POST --header 'content-type:application/json' --header "authorization:Bearer $DB_TOKEN" -d '{"lifetime_seconds": 300, "comment": "TempToken"}' $DB_HOSTNAME/api/2.0/token/create)
TEMP_TOKEN=$(echo $TEMP_RESPONSE | jq '.token_value' | tr -d '"')
TEMP_TOKEN_ID=$(echo $TEMP_RESPONSE | jq '.token_info.token_id' | tr -d '"')

# Delete existing token
curl -X POST --header 'content-type:application/json' --header "authorization:Bearer $TEMP_TOKEN" -d '{"token_id": "'$DB_TOKEN_ID'"}' $DB_HOSTNAME/api/2.0/token/delete

# Get new token and save in key vault
NEW_RESPONSE=$(curl -X POST --header 'content-type:application/json' --header "authorization:Bearer $TEMP_TOKEN" -d '{"lifetime_seconds": 90000, "comment": "'$1'"}' $DB_HOSTNAME/api/2.0/token/create)
NEW_TOKEN=$(echo $NEW_RESPONSE | jq '.token_value' | tr -d '"')
NEW_TOKEN_ID=$(echo $NEW_RESPONSE | jq '.token_info.token_id' | tr -d '"')
az keyvault secret set --vault-name $TF_KEYVAULT_NAME --name $1 --value $NEW_TOKEN
az keyvault secret set --vault-name $TF_KEYVAULT_NAME --name "$1"ID --value $NEW_TOKEN_ID

# Clean up
curl -X POST --header 'content-type:application/json' --header "authorization:Bearer $NEW_TOKEN" -d '{"token_id": "'$TEMP_TOKEN_ID'"}' $DB_HOSTNAME/api/2.0/token/delete

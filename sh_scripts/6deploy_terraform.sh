#!/usr/bin/env bash
# export ARM_CLIENT_ID="070***"
# export ARM_TENANT_ID="bfb***"
# export ARM_SUBSCRIPTION_ID="6d2***"
# export ARM_USE_OIDC=true

terraform apply -var-file="./variables/dev.tfvars" -auto-approve;

#!/usr/bin/env bash
source ./sh_scripts/variables.sh $1

terraform fmt -recursive;
terraform validate;
terraform plan -var-file="./variables/dev.tfvars";

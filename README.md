# README

## Requirements

- Azure CLI
- Terraform
- Databricks CLI
- Access to create requested resources

## Instructions

- Run bash from root: ./sh_scripts/1initialize_remote_state.sh
- Run bash from root: ./sh_scripts/2initialize_github_sp.sh
- Run bash from root: ./sh_scripts/3imports_terraform.sh
- Run bash from root: ./sh_scripts/4validate_terraform.sh
- Run bash from root: ./sh_scripts/5deploy_terraform.sh
- Run bash from root: ./sh_scripts/6rotate_tokens.sh on a schedule if needed

## Useful commands

sed -i 's/\r$//' ./sh_scripts/*
terraform force-unlock 1f10a15f-0d1a-3461-ca78-8235b9408f57
git update-index --chmod=+x ./sh_scripts/x.sh

### Install Terraform Ubuntu

```console
sudo apt-get install unzip
-- https://www.terraform.io/downloads.html   Lookup newest version
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.0.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Install Github CLI Ubuntu

```console
VERSION=`curl  "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-`
wget https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz
curl -sSL https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz -o gh_${VERSION}_linux_amd64.tar.gz
tar xvf gh_${VERSION}_linux_amd64.tar.gz
sudo cp gh_${VERSION}_linux_amd64/bin/gh /usr/local/bin/
sudo cp -r gh_${VERSION}_linux_amd64/share/man/man1/* /usr/share/man/man1/
rm -r gh_2.40.1_linux_amd64.tar.gz
rm -r gh_2.40.1_linux_amd64
```

### Checks & Apply

terraform init -backend-config="./configs/config_dev.azure.tfbackend";
terraform fmt -recursive;
terraform validate;
terraform plan -var-file="./variables/dev.tfvars";
terraform apply -var-file="./variables/dev.tfvars" -auto-approve;

## Description

- main.tf: Entry point for the terraform deployment.
- terraform.tfvars: Global variables. Used in every environment as default value for static variables.
- variables.tf: Variable declarations on a global level, default in terraform.tfvars.
- ./sh_scripts/*: Shell scripts used for creating necessary resources and creating the databricks instance
  - 1initiate_remote_state.azcli: Creates storage account for remote states.
- variables/*: Environment specific variables. Passed via command line to teraform.
- configs/*: Environment specific configurations. Inclduing remote state server and OICD Git Credentials.
- modules/*: Modules of the terraform main.tf file.

## Next steps

- [x] Create Service Principal
- [x] Rotate own user token
- [x] Add SP to workspace via the databricks API
- [ ] Create OAuth token for SP, [](https://docs.databricks.com/en/dev-tools/authentication-oauth.html)
- [ ] Authenticate using SP into Databricks to etch token via the Service Principal
- [ ] Use token to execute API command
- [ ] Put token into Key Vault
- [ ] Set scheduler to update token regularly

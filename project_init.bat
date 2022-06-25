
IF EXIST "C:\\Users\\Junco\\terraform_projects\\%1\" xcopy "%2.tfvars" C:\\Users\\Junco\\terraform_projects\\%1 && del %2.tfvars && cd C:\\Users\\Junco\\terraform_projects\\%1 && git add . && git commit -m "added %2.tfvars. New environment created" && git push
IF NOT EXIST "C:\\Users\\Junco\\terraform_projects\\%1\" mkdir C:\\Users\\Junco\\terraform_projects\\%1 && xcopy * C:\\Users\\Junco\\terraform_projects\\%1 /exclude:exclusions.txt && del %2.tfvars && cd C:\\Users\\Junco\\terraform_projects\\%1 && git init -b main && git add . && git commit -m "initial commit" && gh repo create --source=. --private --push -r "%1" -d "%1 private github repo"

terraform init -upgrade
terraform fmt
terraform workspace new %2
terraform workspace select %2
terraform apply -var-file="%2.tfvars" -auto-approve
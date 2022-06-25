# Platform for deploying a highly available, secure and scalable web hosting architecture to the AWS cloud with Terraform

![alt text](https://github.com/j1nc0/TFG/blob/main/images/TFG.png "infrastructure deployment")

## Dependencies

> :warning: **Make sure to change the hardcoded paths in project_init.bat** Otherwise it will not work in your computer!

- Accounts
    - GitHub
    - AWS
- Software
    - Terraform 1.1 or higher
    - GitHub CLI
    - Git
    - Python 3.9 or higher
- Actions
    - GitHub SSH key pair and GitHub CLI authentication
    - AWS profile must be created in /.aws/credentials file
    - AWS database credentials must be created using AWS secrets manager
    - SSH key pair must be created inside /.ssh folde
    - S3 bucket has to be created: it will store the terraform file state
    - DynamoDB table has to be created: for locking the state file in the remote backend when a user performs a terraform apply

## Usage

Fill all the blank spaces. The create button will not work unless all the inputs are set (except spot price if spot is not selected). Here it is an example:

![alt text](https://github.com/j1nc0/TFG/blob/main/images/GUI_with_contents.png "GUI")

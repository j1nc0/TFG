terraform {
        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
            }
        }

        backend "s3" {
            bucket = "gfds"
 key    = "testProject"
 region = "eu-west-1"
 profile = "dsgfgfd"
dynamodb_table =  "sdfg"

        }
        
        }

        provider "aws" {
        profile    = var.profile
        region     = var.region
        }

        provider "aws" {
        profile    = var.profile
        region     = "us-east-1"
        alias = "us-east-1"
        }
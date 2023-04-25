#
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "i-love-automation"

    workspaces {
      name = "email"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
    node-lambda-packager = {
      source = "jSherz/node-lambda-packager"
      version = "1.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "tfe" {
  token = var.tfe_token
}

provider "node-lambda-packager" {}

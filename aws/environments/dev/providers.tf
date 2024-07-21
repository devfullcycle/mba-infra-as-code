terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }

  backend "s3" {
    bucket         = "fullcycle-terraform"
    key            = "states/terraform.dev.tfstate"
    dynamodb_table = "tf-state-locking"
  }

  required_version = "~> 1.9.2"
}


provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {
  features {}
}
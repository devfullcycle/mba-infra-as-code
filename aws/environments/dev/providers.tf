terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }

  backend "s3" {
    bucket = "fullcycle-terraform"
    key = "states/terraform.dev.tfstate"
    profile = "default"
    dynamodb_table = "tf-state-locking"
  }

  required_version = "~> 1.8.1"
}


provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

provider "azurerm" {
  features {}
}
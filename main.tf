#state will be saved locally
#using version 1.0.1

terraform {
  required_version = ">= 1.0.1" 

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>2.42"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
}
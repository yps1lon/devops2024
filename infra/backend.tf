terraform {
    required_version = ">= 1.9.0"

  backend "s3" {
    bucket = "pgr301-2024-terraform-state" 
    key    = "kn4/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_s3_bucket" "lambda_bucket" {
  bucket = "pgr301-couch-explorers" 
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_s3_bucket" "module_bucket" {
  bucket = "fake-module-bucket"
  acl    = "private"
}
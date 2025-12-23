#-------------------- SAFE --------------------
terraform {
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

#-------------------- HIGH --------------------
# resource "aws_s3_bucket" "bad_bucket" {
#   bucket = "tfsec-test-bucket"
#   acl    = "public-read"
# }

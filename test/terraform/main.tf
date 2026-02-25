terraform {
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

# ------------------ HIGH misconfiguration ------------------
resource "aws_s3_bucket" "bad_bucket" {
  bucket = "tfsec-test-bucket"
  acl    = "public-read"  # triggers misconfig
}

# ------------------ Fake secret ------------------
variable "aws_secret_key" {
  default = "FAKESECRET1234567890"  # triggers secret scan
}

# ------------------ Module with license info ------------------
module "example_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"
}
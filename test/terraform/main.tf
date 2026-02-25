terraform {
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

# ------------------ HIGH misconfiguration ------------------
resource "aws_s3_bucket" "bad_bucket" {
  bucket = "tfsec-test-bucket"
  acl    = "public-read" # triggers misconfiguration scan
}

# ------------------ Fake secret ------------------
variable "aws_access_key" {
  default = "AKIAIOSFODNN7EXAMPLE"
}

# ------------------ Fake module to trigger license scan ------------------
# Use a local module so we avoid network access issues
module "fake_module" {
  source = "./modules/fake_module"
}
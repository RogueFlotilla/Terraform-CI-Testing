# SUMMARY:
# Defines input variables that are used
# throughout the bastion hostinfrastructure

# SUMMARY:
# Defines input variables used throughout the bastion host infrastructure

variable "vpc_id" {
  description = "The ID of the VPC where the bastion host will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for deploying the bastion host."
  type        = string
}

variable "avl_zone" {
  description = "The availability zone for the bastion host."
  type        = string
}

variable "key_name" {
  description = "The SSH key pair name for accessing the bastion host."
  type        = string
}

variable "key_location" {
  description = "The local file path to the SSH key used to access the bastion host."
  type        = string
}

variable "private_key" {
  description = "The private key for SSH access to the bastion host."
  type        = string
}

variable "ssh_user" {
  description = "The SSH username for connecting to the bastion host."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the bastion host instance."
  type        = string
}

variable "trusted_ips" {
  description = "List of trusted IPs for security groups and ACLs"
  type        = list(string)
}


variable "expredvar" { type = bool }
variable "exphavvar" { type = bool }
variable "expslivar" { type = bool }

# variable "vpc_id" {}

# variable "subnet_id" {}

# variable "avl_zone" {}

# variable "key_name" {}

# variable "key_location" {}

# variable "private_key" {}

# variable "ssh_user" {
  
# }

# variable "ami_id" {
  
# }

# // Boolean variable to check whether RedElk was installed or not
# variable "install_redelk" {
#   type = bool
# }

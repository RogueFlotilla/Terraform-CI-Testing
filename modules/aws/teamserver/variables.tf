# SUMMARY:
# Defines input variables that are used
# throughout the teamserver infrastructure

variable "vpc_id" {}

variable "subnet_id" {}

variable "avl_zone" {}

variable "key_name" {}

variable "key_location" {}

variable "private_key" {}

variable "ssh_user" {}

variable "ami_id" {}

variable "bastionhostprivateip" {}

variable "bastionhostpublicip" {}

variable "trusted_ips" {
  description = "List of trusted IPs for security groups and ACLs"
  type        = list(string)
}

# Boolean variables for selecting which C2 server to install based on config.json
variable "expredvar" {
  description = "Set to true if RedELK should be installed on the bastion host."
  type        = bool
  default     = false
}

variable "exphavvar" {
  description = "Set to true if Havoc should be installed on the bastion host."
  type        = bool
  default     = false
}

variable "expslivar" {
  description = "Set to true if Sliver should be installed on the bastion host."
  type        = bool
  default     = false
}

// Optional variables for C2 server installation
variable "install_redelk" {
description = "Boolean variable to control RedELK installation"
type        = bool
default     = false
}

variable "install_havoc" {
description = "Boolean variable to control Havoc installation"
type        = bool
default     = false
}

variable "install_sliver" {
description = "Boolean variable to control Sliver installation"
type        = bool
default     = false
}
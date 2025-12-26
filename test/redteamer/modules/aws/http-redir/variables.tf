# SUMMARY:
# Defines input variables that are used
# throughout the HTTP-redir infrastructure

variable "mycount" {}

variable "vpc_id" {}

variable "ami_id" {}

variable "subnet_id" {}

variable "avl_zone" {}

variable "key_name" {}

variable "key_location" {}

variable "private_key" {}

variable "bastionhostprivateip" {}

variable "bastionhostpublicip" {}

variable "cs_private_ip" {}

variable "ssh_user" {}

variable "expc2var" {
    type = number
}

variable "expredvar" {
    type = bool
}

variable "exphavvar" {
    type = bool
}

variable "expslivar" {
    type = bool
}

variable "install_redelk" {
    type = bool
}

variable "redirect_url" {}

variable "my_uri" {
  
}
# SUMMARY:
# This Terraform file focuses on creating and
# managing infrastructure components, including
# VPC setup, instace provisioning, and software installation
/*
ATTRIBUTION:
This code is based on the original work by Arun 'dazzyddos' Nair, Aravind 'Resillion', and
Soumyadeep 'CRED', available at https://github.com/dazzyddos/HSC24RedTeamInfra. It has been
merged, modified, and expanded on by Natasha 'geeberish' Menon and Richard 'rmf89685' Flores,
under the guidance of Dr. Alex 'ambaziir' Mbaziira, to fulfill the requirements of this research
project. Current project repository available at https://github.com/rmf89685/Redteamer. Project
repository pre-merge available at https://github.com/rmf89685/RT2024-Research-Project-AWS.
*/

// Set Terraform versions to ensure future updates do not break functionality
  // =  Use this exact version number
  // ~> Update versions up to but excluding next major release (i.e. 1.8.5...1.8.6...but NOT 2.0.0)
  
terraform {
  required_version = "= 1.8.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.56.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "= 3.4.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.0.5"
    }    
  }
}

// Configure AWS provider
provider "aws" {
  region = local.region // Set AWS region
  shared_credentials_files = ["${local.shared_files_location}/credentials.txt"] // Pull access credentials
  profile = local.shared_config_profile
}

// Resource that generates a new RSA private key
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// This will save the private key to a file
resource "local_file" "private_key_pem" {
  content  = tls_private_key.key_pair.private_key_pem
  filename = "${local.key_location}${local.key_name}.pem"
}

// This will uploads the generated public key to AWS
resource "aws_key_pair" "generated_public_key" {
  key_name   = local.key_name
  public_key = tls_private_key.key_pair.public_key_openssh
}


// This filters and selects the VM images to use
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] // Canonical's owner ID for Ubuntu images
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"] // Hardware Virtual Machine
  }
}
//Sets the availability zone of the Virtual Private Cloud
module "redteamvpc" {
  source   = "./modules/aws/create_vpc"
  avl_zone = local.avl_zone
}

module "redteambastion" {
  // while the bastion host is being created, it will copy the ssh key file onto it and set the necessary permission (for more info check the main.tf of bastion-host)
  source         = "./modules/aws/bastion_host"
  ami_id         = data.aws_ami.latest_ubuntu.id
  vpc_id         = module.redteamvpc.vpc_id
  subnet_id      = module.redteamvpc.subnet1_id
  avl_zone       = local.avl_zone
  key_name       = aws_key_pair.generated_public_key.key_name
  key_location   = local.key_location
  private_key    = tls_private_key.key_pair.private_key_pem
  ssh_user       = local.ssh_user
  trusted_ips    = local.trusted_ips

  # Conditional C2 installation variables
  expredvar      = local.redvar == 1 ? true : false
  exphavvar      = local.havvar == 1 ? true : false
  expslivar      = local.slivar == 1 ? true : false

}

module "redelk_server" {
  count                   = (module.redteambastion.expredvar && local.redvar == 1) ? 1 : 0
  depends_on              = [module.teamserver]
  source                  = "./modules/aws/redelk"
  ami_id                  = data.aws_ami.latest_ubuntu.id
  vpc_id                  = module.redteamvpc.vpc_id
  subnet_id               = module.redteamvpc.subnet2_id // private subnet
  avl_zone                = local.avl_zone
  key_name                = aws_key_pair.generated_public_key.key_name
  key_location            = local.key_location
  private_key             = tls_private_key.key_pair.private_key_pem
  bastionhostprivateip    = module.redteambastion.bastion_private_ip // for whitelisting 
  bastionhostpublicip     = module.redteambastion.bastion_public_ip
  teamserver_hostname     = "teamserver"
  teamserver_private_ip   = module.teamserver[0].private_ip
  ssh_user                = local.ssh_user
}

module "teamserver" {
  count = (module.redteambastion.exphavvar || module.redteambastion.expslivar) ? 1 : 0

  depends_on             = [module.redteambastion]
  source                 = "./modules/aws/teamserver"
  ami_id                 = data.aws_ami.latest_ubuntu.id
  vpc_id                 = module.redteamvpc.vpc_id
  subnet_id              = module.redteamvpc.subnet2_id // private subnet
  avl_zone               = local.avl_zone
  key_name               = aws_key_pair.generated_public_key.key_name
  key_location           = local.key_location
  private_key            = tls_private_key.key_pair.private_key_pem
  bastionhostprivateip   = module.redteambastion.bastion_private_ip // for whitelisting 
  bastionhostpublicip    = module.redteambastion.bastion_public_ip
  ssh_user               = local.ssh_user
  trusted_ips            = local.trusted_ips

  expredvar      = local.redvar == 1 ? true : false
  exphavvar      = local.havvar == 1 ? true : false
  expslivar      = local.slivar == 1 ? true : false
}

// Provisions HTTP redirector
module "redteamhttpredir" {
  count = local.httpvar == 1 ? 1 : 0
  depends_on = [
      module.redteambastion, module.teamserver
  ]

  source               = "./modules/aws/http-redir"
  mycount              = 1
  vpc_id               = module.redteamvpc.vpc_id
  subnet_id            = module.redteamvpc.subnet1_id // public subnet
  ami_id               = data.aws_ami.latest_ubuntu.id
  avl_zone             = local.avl_zone
  key_name             = aws_key_pair.generated_public_key.key_name
  key_location         = local.key_location
  private_key          = tls_private_key.key_pair.private_key_pem
  bastionhostprivateip = module.redteambastion.bastion_private_ip // for whitelisting 
  bastionhostpublicip  = module.redteambastion.bastion_public_ip
  cs_private_ip        = module.teamserver[0].private_ip
  ssh_user             = local.ssh_user
  install_redelk       = true
  redirect_url         = "www.rmfloresii.github.io"
  my_uri               = "index.html"
  expc2var             = local.expc2var
    
    expredvar      = local.redvar == 1 ? true : false
    exphavvar      = local.havvar == 1 ? true : false
    expslivar      = local.slivar == 1 ? true : false
}

module "gophish" {
    count = local.phishvar == 1 ? 1 : 0
    depends_on = [
        module.redteambastion
    ]

    source               = "./modules/aws/gophish"
    vpc_id               = module.redteamvpc.vpc_id
    subnet_id            = module.redteamvpc.subnet2_id // private subnet
    ami_id               = data.aws_ami.latest_ubuntu.id
    avl_zone             = local.avl_zone
    key_location         = local.key_location
    key_name             = aws_key_pair.generated_public_key.key_name
    private_key          = tls_private_key.key_pair.private_key_pem
    bastionhostprivateip = module.redteambastion.bastion_private_ip // for whitelisting 
    bastionhostpublicip  = module.redteambastion.bastion_public_ip
    ssh_user             = local.ssh_user
}


// Provisions Evilginx
module "evilginx" {
    count = local.evilvar == 1 ? 1 : 0
    depends_on = [
        module.redteambastion
    ]

    source               = "./modules/aws/evilginx"
    vpc_id               = module.redteamvpc.vpc_id
    subnet_id            = module.redteamvpc.subnet1_id // public subnet
    ami_id               = data.aws_ami.latest_ubuntu.id
    avl_zone             = local.avl_zone
    key_name             = aws_key_pair.generated_public_key.key_name
    key_location         = local.key_location
    evilvar              = local.evilvar
    private_key          = tls_private_key.key_pair.private_key_pem
    bastionhostprivateip = module.redteambastion.bastion_private_ip // for whitelisting 
    bastionhostpublicip  = module.redteambastion.bastion_public_ip
    ssh_user             = local.ssh_user
    domain_name          = local.evilginx_domain_name
}

module "webclone-server" {
    count = local.webvar == 1 ? 1 : 0
#    depends_on = [module.namecheap_to_route53]

    mycount              = 1
    source               = "./modules/aws/webserver-clone"
    instance_type        = "t3a.large"
    hostname             = "WebServer"
    ami_id               = data.aws_ami.latest_ubuntu.id
    ssh_user             = "ubuntu"
    vpc_id               = module.redteamvpc.vpc_id
    subnet_id            = module.redteamvpc.subnet1_id
    avl_zone             = local.avl_zone
    key_name             = aws_key_pair.generated_public_key.key_name
    key_location         = local.key_location
    private_key          = tls_private_key.key_pair.private_key_pem
    bastionhostprivateip = module.redteambastion.bastion_private_ip
    bastionhostpublicip  = module.redteambastion.bastion_public_ip
    open_ports           = [443, 80]
    domain_names         = ["www.uwant2.click"]
    website_url          = ["www.scrapethissite.com/pages/"]
}

 resource "null_resource" "ssh_config_cleanup" {
   // This triggers change on every apply, to ensure the destroy provisioner will run even if nothing else changes.
   triggers = {
     always_run = "${timestamp()}"
   }
   }

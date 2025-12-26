// SUMMARY:
# This Terraform file sets variables to be used throughout the code. Specific user settings should
# be set here to prevent having to modify large amounts of code when a user makes small changes.

// ATTRIBUTION:
# This code is based on the original work by Arun "dazzyddos" Nair, Aravind "Resillion", and
# Soumyadeep "CRED", available at https://github.com/dazzyddos/HSC24RedTeamInfra. It has been
# merged with, modified, expanded on by Natasha "geeberish" Menon and Richard "RogueFlotilla"
# Flores, under the guidance of Dr. Alex "ambaziir" Mbaziira, to fulfill the requirements of this
# project. Current project repository available at https://github.com/RogueFlotilla/Redteamer.
# Pre-merge code available at https://github.com/RogueFlotilla/RT2024-Research-Project-AWS.
# Repositories are private and require request to be added as a collaborator to the project.
# merged with, modified, expanded on by Natasha "geeberish" Menon and Richard "RogueFlotilla"
# Flores, under the guidance of Dr. Alex "ambaziir" Mbaziira, to fulfill the requirements of this
# project. Current project repository available at https://github.com/RogueFlotilla/Redteamer.
# Pre-merge code available at https://github.com/RogueFlotilla/RT2024-Research-Project-AWS.
# Repositories are private and require request to be added as a collaborator to the project.

data "external" "my_ip" {
  program = ["bash", "${path.module}/get_my_ip.sh"]
}

locals {
  is_linux = startswith(pathexpand("~"), "/home/")
  region = "us-east-1" # Define AWS region. EXPAND FOR LIST OF REGIONS...

    # --------------------------------------- AWS REGIONS --------------------------------------- #
    #   us-east-1    US East (N. Virginia)          ap-northeast-1 Asia Pacific (Tokyo)           #
    #   us-east-2    US East (Ohio) [DEFAULT]       ap-northeast-2 Asia Pacific (Seoul)           #
    #   us-west-1    US West (N. California)        ap-northeast-3 Asia Pacific (Osaka)           #
    #   us-west-2    US West (Oregon)               ap-east-1      Asia Pacific (Hong Kong)       #
    #                                               ap-south-1     Asia Pacific (Mumbai)          #
    #   ca-west-1    Canada (Calgary)               ap-south-2     Asia Pacific (Hyderabad)       #
    #   ca-central-1 Canada (Central)               ap-southeast-1 Asia Pacific (Singapore)       #
    #                                               ap-southeast-2 Asia Pacific (Sydney)          #
    #   sa-east-1    South America (Sao Paulo)      ap-southeast-3 Asia Pacific (Jakarta)         #
    #                                               ap-southeast-4 Asia Pacific (Melbourne)       #
    #   eu-north-1   Europe (Stockholm)             ap-southeast-5 Asia Pacific (Malaysia         #
    #   eu-south-1   Europe (Milan)                                                               #
    #   eu-south-2   Europe (Spain)                 af-south-1     Africa (Cape Town)             #
    #   eu-west-1    Europe (Ireland)                                                             #
    #   eu-west-2    Europe (London)                me-south-1     Middle East (Bahrain)          #
    #   eu-west-3    Europe (Paris)                 me-central-1   Middle East (UAE)              #
    #   eu-central-1 Europe (Frankfurt)                                                           #
    #   eu-central-2 Europe (Zurich)                us-gov-east-1  AWS GovCloud (US-East)         #
    #                                               us-gov-west-1  AWS GovCloud (US-West)         #
    #   il-central-1   Israel (Tel Aviv)                                    ...as of August 2024  #
    # ------------------------------------------------------------------------------------------- #
  # Path to the config.json file
  config_file = "${local.terraform_parent}/Redteamer/config.json"

  # Decode the JSON content into a local variable
  config_data = jsondecode(file(local.config_file))

  # Extract variables from the config.json file
  expc2var    = local.config_data.expc2var
  evilvar  = local.config_data.expevilvar
  phishvar = local.config_data.expphishvar
  httpvar  = local.config_data.exphttpvar
  redvar   = local.config_data.expredvar
  webvar   = local.config_data.expwebvar
  havvar   = local.config_data.exphavvar
  slivar   = local.config_data.expslivar

  #teamvar  = local.config_data.expteamvar
  # selected_ami = "ami-0010edd796fd9c04d"
  # selected_ami = "ami-0164841dfb52ccc8c" # Minimal Ubuntu
  selected_ami = "ami-020cba7c55df1f615" # Ubuntu Server 24.04 LTS
  
  avl_zone = "${local.region}a" # Define AWS availability zone suffix
  terraform_root = replace( # This replace starts the process of replacing all "\" with "/"
    abspath(path.root), # Define directory of Terraform root at time of apply
    "\\", "/") # Finish replacing all "\" with "/") # Define working directory when terraform was applied
  terraform_parent = replace( # This replace starts the process of replacing all "\" with "/"
    dirname(local.terraform_root), # Define parent directory of Terraform root
    "\\", "/") # Finish replacing all "\" with "/") # Define working directory when terraform was applied
  win_wsl_dir = replace( # This replace starts the process of replacing [DRIVE LETTER]: with /mnt/c
    local.terraform_root, # String to search in replace command: Windows terraform directory
    substr(local.terraform_root, 0, 2), # Replace first two characters (drive letter + ":")...
    "/mnt/${lower(substr(local.terraform_root, 0, 1))}") # ...with "/mnt/" + lowered drive letter
    # If running in Windows, define WSL working directory when terraform was applied
  win_wsl_parent = replace( # This replace starts the process of replacing [DRIVE LETTER]: with /mnt/c
    local.terraform_parent, # String to search in replace command: Windows terraform directory
    substr(local.terraform_root, 0, 2), # Replace first two characters (drive letter + ":")...
    "/mnt/${lower(substr(local.terraform_root, 0, 1))}") # ...with "/mnt/" + lowered drive letter
    # If running in Windows, define WSL working directory when terraform was applied
  shared_files_location = "${local.terraform_parent}/.aws" # Define shared config files directory
  shared_config_profile = "redteamer" # Define shared config profile name; default is "default"
  ssh_user = "ubuntu" # Define default VM username. Likely ubuntu, but may differ (i.e. kali)
  key_location = "${local.terraform_parent}/.aws/key_pairs/" # Define key storage directory
  key_name = "key_pair" # Define access key name
  scripts = "${abspath(path.root)}/scripts" # Define Terraform created scripts directory
  domains = [ # Define list of domain names to transfer from domain registrar
    "newhireintro.com"
  ]
  evilginx_domain_name = "newhireintro.com"
  terraform_host_ip = data.external.my_ip.result.my_ip # IP Address of the Terraform host
  trusted_ips = [local.terraform_host_ip, "10.0.0.0/16"] # Add additional IP's as needed
}



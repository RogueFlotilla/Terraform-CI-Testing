# SUMMARY:
# This Terraform file sets up and configures an Evilginx host
# on AWS, along with associated DNS records

// EC2 instance for the Evilginx host (on-path attack framework)
resource "aws_instance" "evilginx_host" {
  ami                         = var.ami_id
  instance_type               = "t3a.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.evilginx_sg.id]
  availability_zone           = var.avl_zone
  associate_public_ip_address = false
  key_name                    = var.key_name

  // Tags for identification purposes
  tags = {
    Name = "Evilginx_Host"
  }

  // Specifies SSH connection for accessing the Bastion host
  connection {
    type         = "ssh"
    user         = var.ssh_user
    host         = self.private_ip
    bastion_host = var.bastionhostpublicip
    private_key  = var.private_key
  }

  // Sets the hostname of the instance
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname evilginx"
    ]
  }

  // Configures SSH for accessing the instance
  provisioner "local-exec" {
    when    = create
    command = "./create_ssh_config.sh 'evilginx' '${self.private_ip}' 'evilginx' '${var.key_location}${var.key_name}.pem' './ssh_config' 'false'"
  }
}

// Creates a Type A AWS route 53 record
module "create_A_route53_record" {
  depends_on = [aws_instance.evilginx_host]
  source = "../../../modules/aws/create-dns-record"
  key_name = var.key_name
  domain = var.domain_name
  type   = "A" // DNS record that maps a domain to an IPv4 address
  records = {
    "${var.domain_name}" = [aws_instance.evilginx_host.public_ip]
  }
}

// Creates a 1st Type NS AWS route 53 record for Evilginx
module "create_ns1_route53_record_for_evilginx" {

  depends_on = [aws_instance.evilginx_host]

  source = "../../../modules/aws/create-dns-record"

  key_name = var.key_name

  domain = var.domain_name
  type   = "NS"
  records = {
    "ns1.${var.domain_name}" = [aws_instance.evilginx_host.public_ip]
  }
}

// Creates a 2nd Type NS AWS route 53 record for Evilginx
module "create_ns2_route53_record_for_evilginx" {

  depends_on = [aws_instance.evilginx_host]

  source = "../../../modules/aws/create-dns-record"

  key_name = var.key_name

  domain = var.domain_name
  type   = "NS" // Name Server
  records = {
    "ns2.${var.domain_name}" = [aws_instance.evilginx_host.public_ip]
  }
}

// Executes Ansible playbook
resource "null_resource" "run_ansible_playbook" {
  depends_on = [aws_instance.evilginx_host] // Runs only after AWS Evilginx instance has been made

  // Specifies SSH connection for accessing the Bastion host
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.bastionhostpublicip
    private_key = var.private_key
  }

  // Updates the /etc/hosts/ file and associates the private IP to hostnames
  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.evilginx_host.private_ip} evilginx >> /etc/hosts'"
    ]
  }

  // Dynamically create and transfer inventory file
  provisioner "file" {
    content     = templatefile("./Ansible-Playbooks/evilginx/inventory.tpl", { evilginx_private_ip = aws_instance.evilginx_host.private_ip })
    destination = "/home/ubuntu/ansible-playbooks/evilginx/inventory.ini"
  }

  // Executes the evilginx_setup.yml playbook
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-playbooks/evilginx/inventory.ini /home/ubuntu/ansible-playbooks/evilginx/evilginx_setup.yml"
    ]
  }
}

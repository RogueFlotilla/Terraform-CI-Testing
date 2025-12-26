# SUMMARY:
# This Terraform file sets up and configures a GoPhish server on
# an AWS EC2 instance

// EC2 instance for the gophish host (phishing framework)
resource "aws_instance" "gophish_host" {
  ami                         = var.ami_id
  instance_type               = "t3a.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.gophish_sg.id]
  availability_zone           = var.avl_zone
  associate_public_ip_address = false
  key_name                    = var.key_name

  // Tags for identification purposes
  tags = {
    Name = "Gophish_Host"
  }

  // Defines SSH connection variables
  connection {
    type         = "ssh"
    user         = var.ssh_user
    host         = self.private_ip
    bastion_host = var.bastionhostpublicip
    private_key  = var.private_key
  }

  // Sets the hostname of the instance to the hostname variable
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname gophish"
    ]
  }

  // Configures SSH for accessing the instance
  provisioner "local-exec" {
    when    = create
    command = "./create_ssh_config.sh 'gophish' '${self.private_ip}' 'gophish' '${var.key_location}${var.key_name}.pem' './ssh_config' 'false'"
  }
}

// Executes gophish playbook
resource "null_resource" "run_ansible_playbook" {
  depends_on = [aws_instance.gophish_host]

  // Defines SSH configuration for running the playbook
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.bastionhostpublicip
    private_key = var.private_key
  }

  // Updates the /etc/hosts/ file and associates the private IP to hostnames
  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.gophish_host.private_ip} gophish >> /etc/hosts'"
    ]
  }

  // Dynamically create and transfer inventory file
  provisioner "file" {
    content     = templatefile("./Ansible-Playbooks/gophish/inventory.tpl", { gophish_private_ip = aws_instance.gophish_host.private_ip })
    destination = "/home/ubuntu/ansible-playbooks/gophish/inventory.ini"
  }

  // Executes the playbook gophish_setup.yml using the created inventory file
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-playbooks/gophish/inventory.ini /home/ubuntu/ansible-playbooks/gophish/gophish_setup.yml --extra-vars 'PRIVATE_IP=${aws_instance.gophish_host.private_ip}'"
    ]
  }
}

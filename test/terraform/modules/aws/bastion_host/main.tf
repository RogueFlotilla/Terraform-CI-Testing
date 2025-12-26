/*
SUMMARY:
This Terraform file ...

ATTRIBUTION:
This code is based on the original work by Arun 'dazzyddos' Nair, Aravind 'Resillion', and
Soumyadeep 'CRED', available at https://github.com/dazzyddos/HSC24RedTeamInfra. It has been
merged, modified, and expanded on by Natasha 'geeberish' Menon and Richard 'rmf89685' Flores,
under the guidance of Dr. Alex 'ambaziir' Mbaziira, to fulfill the requirements of this research
project. Current project repository available at https://github.com/rmf89685/Redteamer. Project
repository pre-merge available at https://github.com/rmf89685/RT2024-Research-Project-AWS.
*/
/*
SUMMARY:
This Terraform file ...

ATTRIBUTION:
This code is based on the original work by Arun 'dazzyddos' Nair, Aravind 'Resillion', and
Soumyadeep 'CRED', available at https://github.com/dazzyddos/HSC24RedTeamInfra. It has been
merged, modified, and expanded on by Natasha 'geeberish' Menon and Richard 'rmf89685' Flores,
under the guidance of Dr. Alex 'ambaziir' Mbaziira, to fulfill the requirements of this research
project. Current project repository available at https://github.com/rmf89685/Redteamer. Project
repository pre-merge available at https://github.com/rmf89685/RT2024-Research-Project-AWS.
*/

resource "aws_instance" "bastion_host" {
  ami                    = var.ami_id
  instance_type          = "c5.large"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name               = var.key_name

  tags = {
    Name = "Bastion_Host"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.private_key
    host        = aws_instance.bastion_host.public_ip
  }

  provisioner "file" {
    source      = "${var.key_location}${var.key_name}.pem"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "./Ansible-Playbooks"
    destination = "/home/ubuntu/ansible-playbooks"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo hostnamectl set-hostname bastion",
      "sudo apt install net-tools -y",
      "chown ubuntu /home/ubuntu/.ssh/id_rsa",
      "chgrp ubuntu /home/ubuntu/.ssh/id_rsa",
      "chmod 600 /home/ubuntu/.ssh/id_rsa",
      "sudo apt install software-properties-common -y",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y"
    ]
  }

  provisioner "local-exec" {
    when    = create
    command = "./create_ssh_config.sh 'bastion' '${self.public_ip}' '${var.ssh_user}' '${var.key_location}${var.key_name}.pem' './ssh_config' 'true'"
  }
}

resource "null_resource" "install_redelk" {
  count       = var.expredvar ? 1 : 0
  depends_on  = [aws_instance.bastion_host]

  connection {
    type        = "ssh"
    host        = aws_instance.bastion_host.public_ip
    user        = var.ssh_user
    private_key = var.private_key
  }
      // Copies local file to remote instance in temporary storage
    provisioner "file" {
      source = "./modules/aws/redelk/config.cnf"
      destination = "/tmp/redelkconfig.cnf"
    }
  provisioner "remote-exec" {
    inline = [
      "echo Installing RedELK C2 Server...",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook /home/ubuntu/ansible-playbooks/redelk/download_redelk.yml"
    ]
  }
}
# SUMMARY: 
# This Terraform file defines and configures an AWS EC2
# instance and sets up associated Ansible playbook execution
# for RedElk

resource "aws_instance" "teamserver" {
  ami                    = var.ami_id
  instance_type          = "c5.xlarge"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.teamserver-sg.id]
  associate_public_ip_address = false
  availability_zone      = var.avl_zone
  key_name               = var.key_name

// Helps identify as "teamserver"
    tags = {
        Name = "teamserver"
    }

// Defines how Terraform will connect to the inst
    connection {
          type = "ssh"
          user = "ubuntu"
          host = self.private_ip
          bastion_host = var.bastionhostpublicip
          private_key = var.private_key
    }

    root_block_device {
        volume_size = 16
    }

// Sets hostname of EC2 instance to teamserver
// hostnamectl command
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname teamserver"
        ]
    }
}

resource "null_resource" "install_havoc" {
  count       = var.exphavvar ? 1 : 0
  depends_on = [aws_instance.teamserver]

    connection {
          type = "ssh"
          user = var.ssh_user
          host = var.bastionhostpublicip
          private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.teamserver.private_ip} server >> /etc/hosts'"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.teamserver.private_ip} client >> /etc/hosts'"
    ]
  }

  // Dynamically create and transfer inventory file
  provisioner "file" {
    content     = templatefile("./Ansible-Playbooks/havoc/inventory.tpl", { c2_server_private_ip = aws_instance.teamserver.private_ip, c2_client_private_ip = aws_instance.teamserver.private_ip })
    destination = "/home/ubuntu/ansible-playbooks/havoc/inventory.ini"
    #destination = "/mnt/c/Users/Acer/RedTeamResearch/Redteamer/Ansible-Playbooks/teamserver/inventory.ini"
    #destination = "/home/ubuntu/ansible-quickstart/inventory.ini"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Installing Havoc C2 Server...",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-playbooks/havoc/inventory.ini /home/ubuntu/ansible-playbooks/havoc/havoc_rework.yml -vvv"
    ]
  }
}

resource "null_resource" "install_sliver" {
  count       = var.expslivar ? 1 : 0
  depends_on = [aws_instance.teamserver]

    connection {
          type = "ssh"
          user = var.ssh_user
          host = var.bastionhostpublicip
          private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.teamserver.private_ip} server >> /etc/hosts'"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${aws_instance.teamserver.private_ip} client >> /etc/hosts'"
    ]
  }

  // Dynamically create and transfer inventory file
  provisioner "file" {
    content     = templatefile("./Ansible-Playbooks/sliver/inventory.tpl", { c2_server_private_ip = aws_instance.teamserver.private_ip, c2_client_private_ip = aws_instance.teamserver.private_ip })
    destination = "/home/ubuntu/ansible-playbooks/sliver/inventory.ini"
    #destination = "/mnt/c/Users/Acer/RedTeamResearch/Redteamer/Ansible-Playbooks/teamserver/inventory.ini"
    #destination = "/home/ubuntu/ansible-quickstart/inventory.ini"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Installing Sliver C2 Server...",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-playbooks/sliver/inventory.ini /home/ubuntu/ansible-playbooks/sliver/sliver_rework.yml -vvvv"
    ]
  }
}
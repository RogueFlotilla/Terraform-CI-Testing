# SUMMARY:
# This Terraform file sets up and configures HTTP
# redir hosts on AWS EC2 instances, along with optional
# RedELK installation.

# Provisions one or more AWS EC2 instances as HTTP redirection hosts
resource "aws_instance" "httpredir-host" {
    count                       = var.mycount
    ami                         = var.ami_id
    instance_type               = "t3a.small"
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = [aws_security_group.httpredir-sg.id]
    availability_zone           = var.avl_zone
    associate_public_ip_address = false
    key_name                    = var.key_name

    # Configures SSH access to the instance
    connection {
          type = "ssh"
          user = "ubuntu"
          host = self.private_ip
          bastion_host = var.bastionhostpublicip
          private_key = var.private_key
    }

    # Sets the hostname of the instance
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname httpredir${count.index+1}"
        ]
    }

    # Configures SSH for accessing the instance
    provisioner "local-exec" {
        when    = create
        command = "./create_ssh_config.sh 'httpredir${count.index+1}' '${self.private_ip}' '${var.ssh_user}' '${var.key_location}${var.key_name}.pem' './ssh_config' 'false'"
    }

    tags = {
      Name = "httpredir-host${count.index+1}"
    }
}

# Defines local variables in Terraform, httpredir_host_ips is a list
# containing private IP addresses of all EC2 instances created by aws_instance.httpredir-host
locals {
    httpredir_host_ips = aws_instance.httpredir-host.*.private_ip
}

# Copies configuration files to the Bastion host
resource "null_resource" "copy_config_files" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.bastionhostpublicip
    private_key = var.private_key
  }

  provisioner "file" {
    source      = "./modules/aws/http-redir/redelk_httpredir.conf"
    destination = "/tmp/redelk_httpredir.conf"
  }
  provisioner "file" {
    source      = "./modules/aws/http-redir/havoc_httpredir.conf"
    destination = "/tmp/havoc_httpredir.conf"
  }
  provisioner "file" {
    source      = "./modules/aws/http-redir/sliver_httpredir.conf"
    destination = "/tmp/sliver_httpredir.conf"
  }

  depends_on = [aws_instance.httpredir-host]  # Ensure EC2 instance is fully created

  provisioner "remote-exec" {
    inline = [
      "ls -l /tmp"  # List files in /tmp to check if they exist
    ]
  }
}

# Updates /etc/hosts and transfers the inventory file
resource "null_resource" "run_ansible_playbook" {
    depends_on = [aws_instance.httpredir-host, null_resource.copy_config_files]  # Ensure files are copied

    count = length(aws_instance.httpredir-host.*.private_ip)

    # Specifies SSH connection for accessing the Bastion host
    connection {
          type = "ssh"
          user = var.ssh_user
          host = var.bastionhostpublicip
          private_key = var.private_key
    }

    # Updates the /etc/hosts/ file and associates the private IP to hostnames
    provisioner "remote-exec" {
        inline = [
            "sudo -- sh -c 'echo ${aws_instance.httpredir-host[count.index].private_ip} httpredir${count.index+1} >> /etc/hosts'",
            "ls -l /tmp/redelk_httpredir.conf",  # Debugging step to check file existence
            "cat /tmp/redelk_httpredir.conf || echo 'File not found'"  # Additional debugging step
        ]
    }

    # Dynamically create and transfer inventory file
    provisioner "file" {
        content     = templatefile("./Ansible-Playbooks/http-redir/inventory.tpl", { httpredir_private_ip = local.httpredir_host_ips })
        destination = "/home/ubuntu/ansible-playbooks/http-redir/inventory.ini"
    }

    # Executes the http_redirector_setup.yml playbook
    provisioner "remote-exec" {
    inline = [
        "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i /home/ubuntu/ansible-playbooks/http-redir/inventory.ini /home/ubuntu/ansible-playbooks/http-redir/http_redirector_setup.yml --extra-vars \"expc2var=${var.expc2var} C2IP=${var.cs_private_ip[0]} PUBIP=${aws_instance.httpredir-host[count.index].public_ip} REDIRECT_URL=${var.redirect_url} MY_URI=${var.my_uri} HOSTNAME=httpredir${count.index+1}\""
    ]
    }
}

# Installs RedElk, Havoc, or Sliver on HTTP redir host using the playbook
resource "null_resource" "configure_c2" {
  depends_on = [null_resource.run_ansible_playbook]

  count = 1

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.bastionhostpublicip
    private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "case \"${var.expc2var}\" in",
      "  1)",
      "    echo \"Configuring RedELK...\"",
      "    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \\",
      "      -i /home/ubuntu/ansible-playbooks/http-redir/inventory.ini \\",
      "      /home/ubuntu/ansible-playbooks/http-redir/setup_redelk.yml \\",
      "      --extra-vars 'HOSTNAME=httpredir'",
      "    ;;",
      "  *)",
      "    echo \"No C2 chosen.\"",
      "    exit 1",
      "    ;;",
      "esac"
    ]
  }
}

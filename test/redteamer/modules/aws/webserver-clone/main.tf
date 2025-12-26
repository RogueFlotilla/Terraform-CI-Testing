# SUMMARY:
# This Terraform file configures the automation of
# deployment and configuration of EC2 instances, updates
# DNS records, and sets up SSL certificates

resource "aws_instance" "websiteclone-host" {

    count                       = var.mycount
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = [aws_security_group.websiteclone-sg.id]
    availability_zone           = var.avl_zone
    associate_public_ip_address = false
    key_name                    = var.key_name

    //only allowing ssh through bastion
    connection {
        type = "ssh"
        host = self.private_ip
        bastion_host = var.bastionhostpublicip
        user = var.ssh_user
        private_key = var.private_key
    }

// Changes 
    provisioner "remote-exec" {
        inline = [
            "sudo hostname ${var.hostname}"
        ]
    }

    provisioner "local-exec" {
        when    = create
        command = "./create_ssh_config.sh '${var.hostname}' '${self.private_ip}' '${var.ssh_user}' '${var.key_location}${var.key_name}.pem' './ssh_config' 'false'"
    }

    tags = {
        Name = "${var.hostname}"
    }
}

module "create_A_route53_record" {

    source = "../../../modules/aws/create-dns-record"  
    count = length(var.domain_names)
  
    domain = "${var.domain_names[count.index]}"

    key_name = var.key_name
    type = "A"

    records = {
        "${var.domain_names[count.index]}" = [aws_instance.websiteclone-host[count.index].public_ip]
    }
}

resource "null_resource" "run_ansible_websiteclone" {

  depends_on = [ aws_instance.websiteclone-host ]

  count = var.mycount

  connection {
    type        = "ssh"
    host        = var.bastionhostpublicip
    user        = var.ssh_user
    private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -- sh -c 'echo ${var.hostname} ${aws_instance.websiteclone-host[count.index].private_ip} >> /etc/hosts' -vvv",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook /home/ubuntu/ansible-playbooks/website-cloner/main.yml -i ubuntu@${aws_instance.websiteclone-host[count.index].private_ip}, -e 'website_url=${var.website_url[count.index]}' -vvv"
    ]
  }
}

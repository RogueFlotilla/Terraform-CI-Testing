# SUMMARY:
# This Terraform file sets up and configures a RedElk
# server on AWS for security and ease of cloud resource
# deployment

// Creates AWS EC2 instance for RedElk
resource "aws_instance" "RedELK" {
    ami = var.ami_id
    instance_type = "c5.large"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.redelk-sg.id]
    availability_zone = var.avl_zone
    key_name = var.key_name
    private_ip = "10.0.2.103"

    tags = {
        Name = "RedELK_Server"
    }

    // Defines how Terraform connects to the instance
    connection {
          type = "ssh"
          user = "ubuntu"
          host = self.private_ip
          bastion_host = var.bastionhostpublicip
          private_key = var.private_key
    }

    // Changes the hostname of the instance to RedElk
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname redelk"
        ]
    }

    // Executes create_ssh_config script
    provisioner "local-exec" {
        when    = create
        command = "./create_ssh_config.sh 'redelk' '${self.private_ip}' '${var.ssh_user}' '${var.key_location}${var.key_name}.pem' './ssh_config' 'false'"
    }
}

// run elkservers.tgz on the redelk instance
resource "null_resource" "ansible_run_elkserver" {
    // Runs only after the AWS instance of RedElk is created
    depends_on = [ aws_instance.RedELK ]

    // Ensures the resource always runs whenever Terraform apply is run
    triggers = {
        always_run = timestamp()
    }

    // Defines SSH connection to the Bastion host
    connection {
        type        = "ssh"
        host        = var.bastionhostpublicip
        user        = var.ssh_user
        private_key = var.private_key
    }
    
    // Setup_redelk playbook is copied and stored in the RedElk instance
    provisioner "file" {
        source      = "./Ansible-Playbooks/redelk/setup_redelk.yml"
        destination = "/home/ubuntu/ansible-playbooks/redelk/setup_redelk.yml"
    }

    // Dynamically create and transfer inventory file
    provisioner "file" {
        content     = templatefile("./Ansible-Playbooks/redelk/inventory.tpl", { redelk_private_ip = aws_instance.RedELK.private_ip })
        destination = "/home/ubuntu/ansible-playbooks/redelk/inventory.ini"
    }

    // Modifies /etc/hosts file on RedElk server to map RedElk private IP
    // Runs the setup_redelk Ansible Playbook
    // Playbook is run via the generated inv file
    provisioner "remote-exec" {
    inline = [
        "echo 'Installing RedELK Server...'",
        
        # Update package repository and install necessary dependencies
        "sudo apt update -y",   # Update the package list
        "sudo apt install -y net-tools build-essential",  # Install required packages
        
        # Configure /etc/hosts with RedELK IP
        "sudo -- sh -c 'echo ${aws_instance.RedELK.private_ip} redelk >> /etc/hosts'",

        # Run the Ansible playbook for RedELK setup with specified extra variables
        "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-playbooks/redelk/inventory.ini /home/ubuntu/ansible-playbooks/redelk/setup_redelk.yml --extra-vars 'C2IP=${var.teamserver_private_ip[0]} C2HOST=${var.teamserver_hostname}'"
    ]
    }
}
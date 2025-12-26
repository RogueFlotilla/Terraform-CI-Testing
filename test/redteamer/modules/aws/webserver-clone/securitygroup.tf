# SUMMARY:
# This Terraform file defines an WS security group
# to allow web traffic from the internet on specified
# ports, restrict SSH access to a specific bastion host,
# and allow outbound connections freely

// security group for the webserver cloner host, we are opening 80,443 to internet
resource "aws_security_group" "websiteclone-sg" {
    name = "${var.hostname}-sg"
    vpc_id = var.vpc_id

// Creates dynamic ingress rules for the security group
    dynamic "ingress" {
      for_each = var.open_ports

// 0.0.0.0/0 is ant IP address on Internet
      content {
        from_port   = ingress.value
        to_port     = ingress.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

// Ingress rule for port 22 (SSH), allows inbound SSH traffic
// but only from Bastion host's private IP
    ingress {
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["${var.bastionhostprivateip}/32"]
    }

// Allows all outbound traffic from the instance
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

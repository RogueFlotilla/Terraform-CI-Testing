# SUMMARY:
# This Terraform file defines an AWS security group
# for a GoPhish host

// security group for the gophish host
resource "aws_security_group" "gophish_sg" {
  name = "httpredir-sg"
  vpc_id = var.vpc_id

  // Allows port 22 (SSH) traffic from the Bastion host 
  // private IP address, for security
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastionhostprivateip}/32"]
  }

  // Allows port 80 (HTTP) traffic from the Bastion host 
  // from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allows port 443 (HTTPS) traffic from the Bastion host
  // from any IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allows port 3333 (TCP) traffic from Bastion host
  // Gophish admin server listens on port 3333
  ingress {
        from_port   = 3333
        to_port     = 3333
        protocol    = "tcp"
        cidr_blocks = ["${var.bastionhostprivateip}/32"]
  }

  // Allows all outbound traffic to any IP address
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Tags for identification purposes
  tags = {
    Name = "gophish_sg"
  }
}

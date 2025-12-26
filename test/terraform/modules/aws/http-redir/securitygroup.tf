// security group for the httpredir host, we are opening 80,443 to internet
resource "aws_security_group" "httpredir-sg" {
  name = "httpredir-sg-new"
  vpc_id = var.vpc_id

  // Allows all traffic from port 22 (SSH) from the Bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastionhostprivateip}/32"]
  }

  // Allows all web traffic (HTTP) from the Bastion host
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allows all web traffic (HTTPS) from the Bastion host
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Accepts all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpredir-sg"
  }
}

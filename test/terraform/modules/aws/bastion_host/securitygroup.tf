// Security group for the bastion host allowing SSH
resource "aws_security_group" "bastion_sg" {
  name          = "bastion_sg"
  vpc_id        = var.vpc_id
  description   = "Allow SSH to bastion host"

  // Allows all traffic from port 22 (SSH) from the Bastion host
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }

  // Allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
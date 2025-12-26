# SUMMARY:
# This Terraform file defines an AWS security group for 
# a RedElk instance for future log collection,
# analysis, and a web interface for monitoring

// security group for the RedELK instnace, we are opening port 22 only for the bastion host
resource "aws_security_group" "redelk-sg" {
    name = "RedELK-sg"
    vpc_id = var.vpc_id

    // Opens port 22 (SSH) for Bastion Host connections
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.bastionhostprivateip}/32"]
    }

    // Opens port 80 (HTTP) for web traffic
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    // Opens port 443 (HTTPS) for web traffic
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    // Open port 5044 (Logstash) for log collection
    ingress {
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    // Allowss all outbound traffic from RedElk server
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Tags for identification purpose
    tags = {
        Name = "RedELK-sg"
    }
}
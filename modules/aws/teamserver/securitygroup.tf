# SUMMARY:
# This Terraform file defines an AWS security group for
# a teamserver

// security group for the Havoc C2, we are opening port 22 only for the bastion host

resource "aws_security_group" "teamserver-sg" {
    name = "teamserver-sg"
    vpc_id = var.vpc_id

    description   = "Allows communications between C2 infra"

    // Allows all traffic from port 2049 (NFS)
    ingress {
        from_port   = 2049
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    // Allows all traffic from port 2049 (NFS)
    ingress {
        from_port   = 2049
        to_port     = 2049
        protocol    = "udp"
        cidr_blocks = var.trusted_ips
    }

        ingress {
        from_port   = 111
        to_port     = 111
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    // Allows all traffic from port 111 (RPC)
    ingress {
        from_port   = 111
        to_port     = 111
        protocol    = "udp"
        cidr_blocks = var.trusted_ips
    }


    // Allows all traffic from port 40056 (HAVOC C2)
    ingress {
        from_port   = 40056
        to_port     = 40056
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    // Ingress is only open to port 22 (SSH) Bastion host
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.trusted_ips
    }

    ingress {
        from_port   = 40056
        to_port     = 40056
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.trusted_ips
    }

    ingress {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = var.trusted_ips
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "teamserver-sg"
    }
}
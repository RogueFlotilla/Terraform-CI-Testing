// Retrieves public and private IP addresses for later use
output "plaininstance-private-ip" {
  value = concat(aws_instance.websiteclone-host.*.private_ip)
}

output "plaininstance-public-ip" {
  value = concat(aws_instance.websiteclone-host.*.public_ip)
}
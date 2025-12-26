# SUMMARY:
# This is a Terraform config file that automates the setup
# and management of Mailgun domainn and associated
# DNS records within route 53.

terraform {
  // Locks in mailgun version
  required_providers {
    mailgun = {
      source = "wgebis/mailgun"
      version = "0.7.4"
    }
  }
}

// Set Mailgun API key
provider "mailgun" {
  api_key = "<mailgun API Key>"
}

// Domain name path and variable
module "namecheap_to_route53" {
  source = "../../modules/aws/namecheap-to-route53"

  domains = var.mailgun_domain_name
}

// Create a new Mailgun domain
resource "mailgun_domain" "default" {
  depends_on = [
    module.namecheap_to_route53
  ]

  count         = length(var.mailgun_domain_name)
  name          = "${var.mailgun_domain_name[count.index]}"
  region        = var.mailgun_region
  spam_action   = "disabled" // Spam filtering, none but can be set to deleting spam
  dkim_key_size   = 1024  // Number of bits for encryption
}

// Lists domain names and retrieves information from them
data "mailgun_domain" "domain" {
 count = length(var.mailgun_domain_name) 
    depends_on = [
      mailgun_domain.default
    ]
  name = var.mailgun_domain_name[count.index]
}

// Create a new SMTP Mailgun credential
resource "mailgun_domain_credential" "mail_smtp_creds" {
    depends_on = [
      mailgun_domain.default
    ]

    count = length(var.mailgun_domain_name)
    domain = var.mailgun_domain_name[count.index]
    login = var.mailgun_smtp_users[count.index]
    password = var.mailgun_smtp_passwords[count.index]
    region = "us"

// Keeps external password changes from being overwritten
    lifecycle {
        ignore_changes = [password]
    }
}

// Retrieves zone information after Mailgun domain and Namecheap to Route53 resources have been retrieved
data "aws_route53_zone" "selected" {
 count = length(var.mailgun_domain_name)     
    depends_on = [
      mailgun_domain.default, module.namecheap_to_route53
    ]
  name  = var.mailgun_domain_name[count.index]
}

// not needed anymore as we will be pointing MX record to the smtp redirector host
# resource "aws_route53_record" "mailgun-mx" {
#   count = length(var.mailgun_domain_name)     
#   depends_on = [
#       mailgun_domain.default, module.namecheap_to_route53
#   ]
#   zone_id = data.aws_route53_zone.selected[count.index].zone_id
#   name    = data.mailgun_domain.domain[count.index].name
#   type    = "MX"
#   ttl     = 60
#   records = [
#         "${data.mailgun_domain.domain[count.index].receiving_records.0.priority} mail.${var.mailgun_domain_name[count.index]}.",
#   ]
# }

// Automates creation of DKIM records in Route 53 for domains managed by Mailgun
resource "aws_route53_record" "mailgun-dkim" {
  count = length(var.mailgun_domain_name)     
  depends_on = [
      mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "${data.mailgun_domain.domain[count.index].sending_records.1.name}"
  type    = "TXT"
  ttl     = 60 // Time to live
  records = [
        "${data.mailgun_domain.domain[count.index].sending_records.1.value}"
  ]
}

// Automates creation of the Sender Policy Framework protocol 
// in Route 53 for domains manage by Mailgun
resource "aws_route53_record" "mailgun-spf" {
  count = length(var.mailgun_domain_name)     
  depends_on = [
      mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "${data.mailgun_domain.domain[count.index].sending_records.0.name}"
  type    = "TXT"
  ttl     = 60
  records = [
        "${data.mailgun_domain.domain[count.index].sending_records.0.value}",
  ]
}

// Automated resource for the creation of CNAME records
// CNAME records are alternate names for specific domain names
// Includes a weighted routing policy with Rotue 53, choosing how much traffic
// is routed to each source
resource "aws_route53_record" "mailgun-cname" {
  count = length(var.mailgun_domain_name)     
  depends_on = [
      mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "email"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "email"
  records = [
        "mailgun.org"
  ]
}

// we need to add an extra dmarc record to get better score from mail-tester (this domain record addition is not related to mailgun activity)
// Automates DMARC records for Route 53, prevents email spoofing
// p=none means that emails failing DMARC won't be rejected
// Can be applied to multiple domains
// DMARC record is published for domain to control what
// Happens if a message fails authentication
resource "aws_route53_record" "dmarc-record" {
  count = length(var.mailgun_domain_name)     
  depends_on = [
      mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 60
  records = [
        "v=DMARC1; p=none"
  ]
}

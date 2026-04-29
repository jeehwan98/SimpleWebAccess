/**
  Hosted zone is Route53's container for all DNS records under the domain
  prevent_destroy = true — if destroyed, you'd need to re-enter the AWS nameservers at your domain registrar

  FLOW:
  internet
    -> Route53
      -> ALB
        -> Target Group
          -> App containers
*/
resource "aws_route53_zone" "main" {
  name          = "simplewebaccess.com"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

/**
  alias record instead of a CNAME because ALBs have dynamic IPs that change over time
  Route53 alias resolves directly to the ALB and tracks its IPs automatically
*/
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "simplewebaccess.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.simplewebaccess.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prometheus.simplewebaccess.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "grafana.simplewebaccess.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "argocd" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "argocd.simplewebaccess.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

output "route53_nameservers" {
  description = "Set these nameservers at your domain registrar (one-time setup)"
  value       = aws_route53_zone.main.name_servers
}

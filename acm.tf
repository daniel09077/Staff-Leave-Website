# #create public certificate
# resource "aws_acm_certificate" "SLV_cert" {
#   domain_name = var.domain_name
#   #sub domains:
#   subject_alternative_names = [
#     "www.${var.domain_name}",
#     "*.${var.domain_name}"
#   ]
#   validation_method = "DNS"


#   lifecycle {
#     create_before_destroy = true

#   }
# }
# #let Terraform aware of the hosted zone in the AWS 
# data "aws_route53_zone" "hosted_zone" {
#   name         = var.domain_name
#   private_zone = false
# }

# resource "aws_route53_record" "cert_r53_record" {
#   for_each = {
#     for dvo in aws_acm_certificate.SLV_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.hosted_zone.zone_id
# }

# resource "aws_acm_certificate_validation" "SLV_cert_validation" {
#   certificate_arn         = aws_acm_certificate.SLV_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_r53_record : record.fqdn]
# }

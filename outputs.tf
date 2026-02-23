

# output "application_url" {
#   description = "The main URL to access your application"
#   value       = "https://${var.domain_name}"
# }



# output "alb_dns_name" {
#   description = "The direct DNS name of the Load Balancer (for testing)"
#   value       = aws_lb.SLV_alb.dns_name
# }

# output "ssh_connection_string" {
#   description = "Copy-paste this command to SSH into your primary web server"
#   value       = "ssh -i ${local_sensitive_file.private_key_pem.filename} ec2-user@${aws_instance.web_server[0].public_ip}"
# }


# output "rds_endpoint" {
#   description = "The address of your RDS instance (useful for config files/debugging)"
#   value       = aws_db_instance.mysql.endpoint
# }

# output "rds_db_name" {
#   description = "The name of the database created in RDS"
#   value       = aws_db_instance.mysql.db_name
# }

# output "s3_bucket_name" {
#   description = "The ID of the S3 bucket used for vendor assets"
#   value       = aws_s3_bucket.vendors_bucket.id
# }


# output "certificate_status" {
#   description = "The validation status of your ACM certificate"
#   value       = aws_acm_certificate.SLV_cert.status
# }

# output "vpc_id" {
#   description = "The ID of the VPC housing your infrastructure"
#   value       = aws_vpc.Staff_Leave_VPC.id
# }
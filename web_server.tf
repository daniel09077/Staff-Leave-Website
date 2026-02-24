resource "aws_instance" "web_servers" {
  count           = 2 # Create TWO servers
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.alb_sg.id]
  # This picks subnet [0] for the first server and [1] for the second
  subnet_id            = values(local.app_subnet_ids)[count.index]
  iam_instance_profile = aws_iam_instance_profile.php_ssm_profile.name
  user_data = templatefile("${path.module}/user_data.tftpl", {
    db_host           = aws_db_instance.mysql.address
    db_name           = aws_db_instance.mysql.db_name
    db_user           = aws_db_instance.mysql.username
    cloudfront_domain = aws_cloudfront_distribution.main.domain_name
    s3_bucket         = aws_s3_bucket.vendors_bucket.id
    db_password       = random_password.db_password.result

  })

  tags = {
    Name = "Web-Server-${count.index + 1}"
  }
}
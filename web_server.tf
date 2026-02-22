resource "aws_instance" "web_server" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.alb_sg.id]
  # This picks subnet [0] for the first server and [1] for the second
  subnet_id = local.public_subnet_ids

  user_data = templatefile("${path.module}/user_data.tftpl", {
    db_endpoint       = aws_db_instance.mysql.address
    db_name           = aws_db_instance.mysql.db_name
    db_user           = aws_db_instance.mysql.username
    cloudfront_domain = aws_cloudfront_distribution.main.domain_name
    s3_bucket         = aws_s3_bucket.vendors_bucket.id
  })

  tags = {
    Name = "Web-Server"
  }
}
resource "aws_launch_template" "web_server_LT" {
  name          = "web_server_LT"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    db_host           = aws_db_instance.mysql.address
    db_name           = aws_db_instance.mysql.db_name
    db_user           = aws_db_instance.mysql.username
    cloudfront_domain = aws_cloudfront_distribution.main.domain_name
    s3_bucket         = aws_s3_bucket.vendors_bucket.id
    db_password       = random_password.db_password.result
  }))

}

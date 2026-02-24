resource "aws_launch_template" "web_server_LT" {
  name          = "web_server_LT"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    cloudfront_domain = aws_cloudfront_distribution.main.domain_name
  }))

}

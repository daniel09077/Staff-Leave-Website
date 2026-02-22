resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow cloudfront send traffic"
  vpc_id      = aws_vpc.Staff_Leave_VPC.id

  tags = {
    Name = "alb_sg"
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}







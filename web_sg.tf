resource "aws_security_group" "web_sg" {
  name        = "app-ec2-sg"
  description = "Allow traffic only from ALB"
  vpc_id      = aws_vpc.Staff_Leave_VPC.id

  # Allow HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # (Optional) Allow SSH only from your IP (NOT 0.0.0.0/0)
  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["105.112.238.157/32"]
  }

  # Allow outbound traffic (needed for yum, S3, etc.)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-ec2-sg"
  }
}

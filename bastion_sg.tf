resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow traffic only from my IP"
  vpc_id      = aws_vpc.Staff_Leave_VPC.id

  # Allow HTTP from my IP only 
  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["105.117.8.226/32"]
  }



  tags = {
    Name = "bastion-sg"
  }
}

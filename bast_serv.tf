resource "aws_instance" "bastion_servers" {
  count           = 2 # Create TWO servers
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.bastion_sg.id]
  # This picks subnet [0] for the first server and [1] for the second
  subnet_id = values(local.public_subnet_ids)[count.index]
  key_name  = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "Bastion-Server-${count.index + 1}"
  }
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "staffleave-db-group"
  subnet_ids = values(local.db_subnet_ids)

  tags = { Name = "Main DB Subnet Group" }
}
resource "aws_security_group" "rds_sg" {
  name   = "SLS-rds-SG"
  vpc_id = aws_vpc.Staff_Leave_VPC.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    # 
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "mysql" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro" # Free Tier eligible
  db_name           = "aci_leave"
  username          = "admin"
  password          = var.db_password # Use a sensitive variable!

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Crucial for security:
  publicly_accessible = false
  skip_final_snapshot = true # Set to 'false' for production!

  performance_insights_enabled = false
}

resource "random_password" "db_password" {
  length  = 8
  special = true
  # This line tells Terraform NOT to use the characters RDS forbids
  override_special = "!#$%&*()-_=+[]{}:?<>"
}
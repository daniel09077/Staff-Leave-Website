resource "aws_vpc" "Staff_Leave_VPC" {
  cidr_block = var.cidr_blocks[0]
  tags = {
    Name = "Staff_Leave_VPC"
  }
}
#public subnet az 1 
resource "aws_subnet" "pub_sub_az1" {
  vpc_id     = aws_vpc.Staff_Leave_VPC.id
  cidr_block = var.cidr_blocks[1]

  tags = {
    Name = "pub_sub_az1"
  }
}

#public subnet az2
resource "aws_subnet" "pub_sub_az2" {
  vpc_id     = aws_vpc.Staff_Leave_VPC.id
  cidr_block = var.cidr_blocks[2]

  tags = {
    Name = "pub_sub_az2"
  }
}

#private subnet 1 (Hosts the Application webserver)
resource "aws_subnet" "app_sub_az1" {
  vpc_id            = aws_vpc.Staff_Leave_VPC.id
  cidr_block        = var.cidr_blocks[3]
  availability_zone = var.avail_zone[0]
  tags = {
    Name = "app_sub_az1"
  }
}
#private subnet 2 (Hosts the Application webserver)
resource "aws_subnet" "app_sub_az2" {
  vpc_id            = aws_vpc.Staff_Leave_VPC.id
  cidr_block        = var.cidr_blocks[4]
  availability_zone = var.avail_zone[1]
  tags = {
    Name = "app_sub_az2"
  }
}

#private subnet 3 (Hosts the RDS server)
resource "aws_subnet" "db_sub_az1" {
  vpc_id            = aws_vpc.Staff_Leave_VPC.id
  cidr_block        = var.cidr_blocks[5]
  availability_zone = var.avail_zone[0]
  tags = {
    Name = "db_sub_az1"
  }
}
resource "aws_subnet" "db_sub_az2" {
  vpc_id            = aws_vpc.Staff_Leave_VPC.id
  cidr_block        = var.cidr_blocks[6]
  availability_zone = var.avail_zone[1]
  tags = {
    Name = "db_sub_az2"
  }
}
#create internet gateway
resource "aws_internet_gateway" "SLV_IGW" {
  vpc_id = aws_vpc.Staff_Leave_VPC.id

  tags = {
    Name = "SLV-IGW"
  }
}

#route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.Staff_Leave_VPC.id
}
#route to the internet via the internet gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.SLV_IGW.id
}
#route table association to public subnets
resource "aws_route_table_association" "public_subnets_association" {
  for_each       = toset(local.public_subnet_ids)
  subnet_id      = each.value # ✅ one at a time
  route_table_id = aws_route_table.public_rt.id
}
#create private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.Staff_Leave_VPC.id
}
#create NATgateway
resource "aws_nat_gateway" "SLV_NATGW" {
  # Use for_each to turn the tuple into individual resources
  allocation_id = aws_eip.nat.id
  for_each      = toset(local.public_subnet_ids)
  subnet_id     = each.value # ✅ one at a time
  #subnet_id     = aws_subnet.pub_sub_az1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.SLV_IGW]
}
#specify route to the Natgateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.SLV_NATGW.id
}
#association the private subnets to the natgateway
resource "aws_route_table_association" "pri_subnet_association" {
  for_each       = merge(local.app_subnet_ids, local.db_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}
#Reserve the Static Public IP
resource "aws_eip" "nat" {
  domain = "vpc"
}

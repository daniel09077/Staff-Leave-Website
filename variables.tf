locals {
  public_subnet_ids = [
    aws_subnet.pub_sub_az1.id,
    aws_subnet.pub_sub_az2.id
  ]
  # Map of Web Server subnets
  app_subnet_ids = [
    aws_subnet.app_sub_az1.id,
    aws_subnet.app_sub_az2.id
  ]

  # Map of Database subnets
  db_subnet_ids = [
    aws_subnet.db_sub_az1.id,
    aws_subnet.db_sub_az2.id
  ]

}


variable "project_name" {
  default = "Staff Leave System"
}
#VPC variables
variable "cidr_blocks" {
  default = ["10.0.0.0/16", "10.0.1.0/24", "10.0.2.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}
variable "avail_zone" {
  default = ["us-east-1a", "us-east-1b"]
}

#Guard duty variables
variable "endpointemail" {
  default = "danielokuguni855@gmail.com"
}
variable "GD-publisher_SNS" {
  default = "GD-publisher-SNS"
}
variable "lambda_rt" {
  default = "python3.9"
}
#certificate manager variables
variable "domain_name" {
  default = "tempestcloudsolutions.click"
}
variable "alternative_domain_name" {
  default = "*.tempestcloudsolutions.click"
}
#instance variables
variable "instance_name" {
  default = "web-server"
}
variable "ami" {
  default = "ami-0c1fe732b5494dc14"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "db_password" {
  description = ""
  default     = "21359555"
  type        = string
  sensitive   = true
}
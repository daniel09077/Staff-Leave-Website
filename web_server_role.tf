# Create the Role
resource "aws_iam_role" "php_ssm_role" {
  name = "php-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach the Amazon-managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.php_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the Profile to attach to the EC2
resource "aws_iam_instance_profile" "php_ssm_profile" {
  name = "php-ssm-profile"
  role = aws_iam_role.php_ssm_role.name
}

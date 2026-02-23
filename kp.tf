# # 1. Generate a new Private Key
# resource "tls_private_key" "main_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # 2. Create the AWS Key Pair using the generated public key
# resource "aws_key_pair" "generated_key" {
#   key_name   = "staff-leave-key"
#   public_key = tls_private_key.main_key.public_key_openssh
# }

# # 3. Save the Private Key to your local machine (so you can SSH later)
# resource "local_sensitive_file" "private_key_pem" {
#   content  = tls_private_key.main_key.private_key_pem
#   filename = "${path.module}/staff-leave-key.pem"
# }
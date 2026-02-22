# #Create Load Balancer
# resource "aws_lb" "SLV_alb" {
#   name               = "SLV-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = local.public_subnet_ids

#   enable_deletion_protection = false

#   tags = {
#     Name = "${var.project_name}-alb"
#   }
# }
# #create target group
# resource "aws_lb_target_group" "SLV-tg" {
#   name     = "SLS-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.Staff_Leave_VPC.id

#   health_check {
#     path                = "/index.php"
#     matcher             = "200-399"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2

#   }
#   lifecycle {
#     create_before_destroy = "true"
#   }
# }
# #target group listener on 80
# resource "aws_lb_listener" "ALB-listner_80" {
#   load_balancer_arn = aws_lb.SLV_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = 443
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
# #target group listener on HTTPS
# resource "aws_lb_listener" "ALB-listner" {
#   load_balancer_arn = aws_lb.SLV_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.SLV_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.SLV-tg.arn
#   }
# }


resource "aws_autoscaling_group" "app" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 4
  vpc_zone_identifier = values(local.app_subnet_ids)

  launch_template {
    id      = aws_launch_template.web_server_LT.id
    version = "$Latest"
  }

  target_group_arns    = [aws_lb_target_group.SLV-tg.arn]
  termination_policies = ["OldestInstance"]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 300
    }
  }

  health_check_type         = "ELB"
  health_check_grace_period = 60
}


resource "aws_lb" "elbv2_sac" {
  name                       = "elbv2-sac"
  load_balancer_type         = "network"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = true
  enable_deletion_protection = false
  subnets = [aws_subnet.elbv2_subnet_1.id]
  access_logs {
    bucket = aws_s3_bucket.elbv2_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn
  port              = 99
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.elbv2_user_pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.elbv2_user_pool_client.id
      user_pool_domain    = aws_cognito_user_pool_domain.elbv2_user_pool_domain.domain
      authentication_request_extra_params = {
        key = "value"
      }
      on_unauthenticated_request = "allow"
      session_timeout = 1000
    }
  }
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id      = aws_vpc.ec2_instance_vpc_default.id
  port        = 80
  protocol    = "TCP"
  health_check {
    enabled  = false
    protocol = "HTTP"
  }
  stickiness {
    enabled = false
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

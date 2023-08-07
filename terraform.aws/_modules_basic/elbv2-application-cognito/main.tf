
resource "aws_lb" "elbv2_sac" {
  name                       = "elbv2-sac"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = false
  enable_deletion_protection = false
  subnet_mapping {
    subnet_id = aws_subnet.elbv2_subnet_1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.elbv2_subnet_2.id
  }
  access_logs {
    bucket  = aws_s3_bucket.elbv2_bucket.bucket
    enabled = false
  }
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id      = aws_vpc.ec2_instance_vpc_default.id
  port        = 80
  protocol    = "HTTP"
  health_check {
    enabled  = true
    protocol = "HTTP"
  }
  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener_rule" "elbv2-listener-rule" {
  listener_arn = aws_lb_listener.elbv2_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elbv2_target_group.arn
    authenticate_cognito {
      on_unauthenticated_request = "allow"
      session_cookie_name        = ""
      session_timeout            = 3600
      user_pool_arn              = aws_cognito_user_pool.elbv2_user_pool.arn
      user_pool_client_id        = aws_cognito_user_pool_client.elbv2_user_pool_client.id
      user_pool_domain           = aws_cognito_user_pool_domain.elbv2_user_pool_domain.domain
    }
  }
  condition {
    host_header {
      values = ["example.com"]
    }
  }
}

resource "aws_lb_listener" "elbv2_listener" {
  load_balancer_arn = aws_lb.elbv2_sac.arn
  port              = 99
  protocol          = "HTTP"
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
      session_timeout = 100000
    }
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

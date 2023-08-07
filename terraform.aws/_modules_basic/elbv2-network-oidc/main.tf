
resource "aws_lb" "elbv2_sac" {
  name                       = "elbv2-sac"
  load_balancer_type         = "network"
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "monitor"
  internal                   = true
  enable_deletion_protection = false
  subnets                    = [aws_subnet.elbv2_subnet_1.id]
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
    authenticate_oidc {
      on_unauthenticated_request = "allow"
      session_cookie_name        = "sac-testing-cookie"
      session_timeout            = 300
      client_id                  = ""
      client_secret              = ""
      issuer                     = "https://oak9.okta.com/oauth2/default"
      token_endpoint             = "https://oak9.okta.com/oauth2/default/v1/token"
      authorization_endpoint     = "https://oak9.okta.com/oauth2/default/v1/authorize"
      user_info_endpoint         = "https://oak9.okta.com/oauth2/default/v1/userinfo"
    }
  }
}

resource "aws_lb_target_group_attachment" "elbv2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elbv2_target_group.arn
  target_id        = aws_instance.aws_ec2_instance_sac_default.id
}

resource "aws_lb_target_group" "elbv2_target_group" {
  name        = "elbv2-target-group-sac"
  target_type = "instance"
  vpc_id      = aws_vpc.ec2_instance_vpc_default.id
  port        = 80
  protocol    = "TCP"
  health_check {
    enabled  = true
    protocol = "HTTP"
  }
  stickiness {
    enabled = false
  }
}

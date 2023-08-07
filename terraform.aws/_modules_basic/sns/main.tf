
resource "aws_sns_topic" "sac_sns_topic" {
  name         = "sac-testing-sns"
  display_name = "sac-test-sns"
}

resource "aws_sns_topic_policy" "sac_sns_policy" {
  arn = aws_sns_topic.sac_sns_topic.arn
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Describe the policy statement",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "sns:Protocol": "https"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "sac_sns_topic_subscription" {
  topic_arn = aws_sns_topic.sac_sns_topic.arn
  protocol  = "http"
  endpoint  = "http://devapi.oak9.cloud/console/"
}

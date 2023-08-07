
resource "aws_secretsmanager_secret_rotation" "secrets_manager_rotation" {
  secret_id           = aws_secretsmanager_secret.sac_secrets_manager_insecure.id
  rotation_lambda_arn = aws_lambda_function.secure_lambda_SAC.arn
  rotation_rules {
    automatically_after_days = 90
  }
}

resource "aws_secretsmanager_secret" "sac_secrets_manager_insecure" {
  name        = "sac-testing-secrets-manager-insecure"
  description = "Default config2"
  recovery_window_in_days = 10
}

resource "aws_secretsmanager_secret_policy" "sac_secrets_manager_policy" {
  secret_arn = aws_secretsmanager_secret.sac_secrets_manager_insecure.arn
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAnotherAWSAccountToReadTheSecret",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

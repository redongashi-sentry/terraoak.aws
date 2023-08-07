
resource "aws_instance" "aws_ec2_instance_sac_default" {
  ami       = data.aws_ami.ubuntu.id
  subnet_id = aws_subnet.ec2_instance_subnet_default.id
  launch_template {
    id = aws_launch_template.aws_ec2_launch_template_sac_default.id
  }
  associate_public_ip_address = true
  monitoring = false
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = false
    volume_size = 5
    tags = {
      "key" = "value"
    }
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_launch_template" "aws_ec2_launch_template_sac_default" {
  name                                 = "ec2-instance-launch-template-sac-default"
  default_version                      = 1
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  tags = {
    "key" = "value"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

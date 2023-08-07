
resource "aws_ecs_cluster" "sac_ecs_cluster" {
  name = "sac-testing-ecs-cluster"
}

resource "aws_ecs_service" "sac_ecs_service" {
  name            = "sac-testing-ecs-service"
  cluster         = aws_ecs_cluster.sac_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.sac_ecs_task_definition.arn
  launch_type     = "EC2"
}

resource "aws_ecs_task_definition" "sac_ecs_task_definition" {
  family = "sac-ecs-task-def"
  container_definitions = jsonencode([{
    "memory" : 32,
    "essential" : true,
    "entryPoint" : [
      "ping"
    ],
    "name" : "alpine_ping",
    "readonlyRootFilesystem" : true,
    "image" : "alpine:3.4",
    "command" : [
      "-c",
      "4",
      "google.com"
    ],
    "cpu" : 16
  }])
  cpu          = 1024
  memory       = 2048
  network_mode = "none"
  volume {
    name = "myEfsVolume"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.sac_ecs_efs.id
      transit_encryption = "DISABLED"
      authorization_config {
        iam = "DISABLED"
      }
    }
  }
}

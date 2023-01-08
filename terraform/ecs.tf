resource "aws_ecs_cluster" "ecs_cluster" {
  name = "cluster-${var.project_name}"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family = "task-${var.project_name}"
  cpu = 256
  memory = 512
  execution_role_arn       = "arn:aws:iam::${var.aws_id}:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::${var.aws_id}:role/ecsTaskExecutionRole"
  container_definitions    = <<TASK_DEFINITION
[
    {
        "name": "${var.project_name}",
        "image": "${docker_image.docker.name}",
        "essential": true,
        "portMappings":
        [
            {
                "protocol": "tcp",
                "containerPort": 3000,
                "hostPort": 3000
            }
        ],
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.cloudwatch_log_group.id}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
      }
    }
]
TASK_DEFINITION
}
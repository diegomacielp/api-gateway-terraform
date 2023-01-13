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
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family                   = "task-${var.project_name}"
  cpu                      = 256
  memory                   = 512
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

resource "aws_ecs_service" "ecs_service" {
  name                               = "service-${var.project_name}"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  network_configuration {
    security_groups  = [aws_security_group.security_group_ecs.id]
    subnets          = [for s in data.aws_subnet.subnet : s.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    container_name   = var.project_name
    container_port   = var.project_port
  }
}
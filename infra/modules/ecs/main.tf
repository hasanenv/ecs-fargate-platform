resource "aws_ecs_cluster" "gatus_cluster" {
  name = "gatus-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "gatus_log_group" {
  name = "gatus-log-group"

  tags = local.tags
}

resource "aws_ecs_task_definition" "gatus_task_def" {
  family                   = "gatus-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "gatus"
      image = "${var.image_url}:${var.image_tag}"
      essential = true

      secrets = [
        {
          name      = "GATUS_CONFIG"
          valueFrom = var.gatus_config_ssm_arn
        }
      ]

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.gatus_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.tags
}

resource "aws_ecs_service" "gatus_service" {
  name            = "gatus-service"
  cluster         = aws_ecs_cluster.gatus_cluster.id
  task_definition = aws_ecs_task_definition.gatus_task_def.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "gatus"
    container_port   = 8080
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }

  tags = local.tags
}
# ECS service
resource "aws_ecs_service" "backend" {
  name                               = "${var.env}-backend"
  cluster                            = aws_ecs_cluster.this.arn
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  # 検証環境ではECS-Execによるコンテナへの直接アクセスを許可する
  enable_execute_command = var.env == "stg" ? true : false

  # 検証環境ではFargate-spotを使ってコストダウン
  capacity_provider_strategy {
    capacity_provider = var.env == "stg" ? "FARGATE_SPOT" : "FARGATE"
    weight            = 1
    base              = 1
  }
  # デプロイが失敗した場合にロールバックする
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      module.backend_sg.security_group_id,
      module.backend_sg_peer.security_group_id
    ]

    subnets = [
      aws_subnet.private_app_1a.id,
      aws_subnet.private_app_1c.id
    ]
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
    port         = 80
  }
}

# Task definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
  skip_destroy             = false
  container_definitions = jsonencode([
    {
      name      = "backend",
      image     = "nginx:latest",
      essential = true,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "backend",
          awslogs-group         = "/ecs/backend"
        }
      },
      portMappings = [
        {
          protocol      = "tcp",
          containerPort = 80
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
    }
  ])
}

# Service Discovery
resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 60
      type = "A"
    }
    dns_records {
      ttl  = 60
      type = "SRV"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# CoudWatch logs
resource "aws_cloudwatch_log_group" "for_ecs_backend" {
  name              = "/ecs/backend"
  retention_in_days = var.logs_retention_in_days
}





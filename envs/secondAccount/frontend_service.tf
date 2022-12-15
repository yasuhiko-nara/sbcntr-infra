# # Target Group
# resource "aws_lb_target_group" "frontend" {
#   name                 = "frontend-target-group"
#   target_type          = "ip"
#   vpc_id               = aws_vpc.this.id
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = 300

#   health_check {
#     path                = "/"
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#   }

#   depends_on = [aws_lb.this]
# }

# # Listener rule
# resource "aws_lb_listener_rule" "frontend" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

# # ECS service
# resource "aws_ecs_service" "frontend" {
#   name                               = "${var.env}-frontend"
#   cluster                            = aws_ecs_cluster.this.arn
#   task_definition                    = aws_ecs_task_definition.frontend.arn
#   desired_count                      = var.desired_count
#   health_check_grace_period_seconds  = 60
#   deployment_minimum_healthy_percent = 100
#   deployment_maximum_percent         = 200
#   # 検証環境ではECS-Execによるコンテナへの直接アクセスを許可する
#   enable_execute_command = var.env == "stg" ? true : false

#   # 検証環境ではFargate-spotを使ってコストダウン
#   capacity_provider_strategy {
#     capacity_provider = var.env == "stg" ? "FARGATE_SPOT" : "FARGATE"
#     weight            = 1
#     base              = 1
#   }
#   # デプロイが失敗した場合にロールバックする
#   deployment_circuit_breaker {
#     enable   = true
#     rollback = true
#   }

#   network_configuration {
#     assign_public_ip = false
#     security_groups  = [module.frontend_sg.security_group_id]

#     subnets = [
#       aws_subnet.private_app_1a.id,
#       aws_subnet.private_app_1c.id
#     ]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.frontend.arn
#     container_name   = "frontend"
#     container_port   = 80
#   }

#   lifecycle {
#     ignore_changes = [task_definition]
#   }
# }

# # Task definition
# resource "aws_ecs_task_definition" "frontend" {
#   family                   = "frontend"
#   cpu                      = var.cpu
#   memory                   = var.memory
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
#   task_role_arn            = module.ecs_task_role.iam_role_arn
#   skip_destroy             = false
#   container_definitions = jsonencode([
#     {
#       name      = "frontend",
#       image     = "nginx:latest",
#       essential = true,
#       logConfiguration = {
#         logDriver = "awslogs",
#         options = {
#           awslogs-region        = "ap-northeast-1",
#           awslogs-stream-prefix = "frontend",
#           awslogs-group         = "/ecs/frontend"
#         }
#       },
#       portMappings = [
#         {
#           protocol      = "tcp",
#           containerPort = 80
#         }
#       ],
#       linuxParameters = {
#         initProcessEnabled = true
#       },
#       # タスク起動時に環境変数をSecret Managerから読み取る
#       # secrets = [
#       #   {
#       #     name      = "SAMPLE",
#       #     valueFrom = "arn:aws:secretsmanager:ap-northeast-1:210217920752:secret:stg/frontend/sample-YRpOJK:SAMPLE::"
#       #   }
#       # ]
#     }
#   ])
# }

# # CoudWatch logs
# resource "aws_cloudwatch_log_group" "for_ecs_frontend" {
#   name              = "/ecs/frontend"
#   retention_in_days = var.logs_retention_in_days
# }

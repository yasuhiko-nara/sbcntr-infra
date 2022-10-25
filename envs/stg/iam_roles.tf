
# TaskExecutionRole
## ECRからイメージをpullしたり、Cloudwatchにlogを送付する
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
## SSMにアクセスする
data "aws_iam_policy" "ssm_read_only_access" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
## Secret Managerにアクセスする
data "aws_iam_policy" "secrets_manager_read_write_policy" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy, data.aws_iam_policy.ssm_read_only_access.policy, data.aws_iam_policy.secrets_manager_read_write_policy.policy]
}

module "ecs_task_execution_role" {
  source     = "../../modules/iam_role"
  name       = "ecs-task-execution-role"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}


# ECS task role
data "aws_iam_policy_document" "ecs_task_role" {
  # Ecs-execを許可する
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

module "ecs_task_role" {
  source     = "../../modules/iam_role"
  name       = "ecs-task-role"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_role.json
}

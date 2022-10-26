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
  source_policy_documents = [
    data.aws_iam_policy.ecs_task_execution_role_policy.policy,
    data.aws_iam_policy.ssm_read_only_access.policy,
    data.aws_iam_policy.secrets_manager_read_write_policy.policy
  ]
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


# CodeBuild
data "aws_iam_policy_document" "codebuild" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission"
    ]
  }
  statement {
    effect    = "Allow"
    resources = [var.github_connection_arn]
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
  }
  # statement {
  #   effect    = "Allow"
  #   resources = ["*"]
  #   actions   = ["*"]
  # }
}

module "codebuild_role" {
  source     = "../../modules/iam_role"
  name       = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy_document.codebuild.json
}


# CodePipeline
data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
  statement {
    effect    = "Allow"
    resources = [var.github_connection_arn]
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
  }
  # statement {
  #   effect    = "Allow"
  #   resources = ["*"]
  #   actions   = ["*"]
  # }

}
module "codepipeline_role" {
  source     = "../../modules/iam_role"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

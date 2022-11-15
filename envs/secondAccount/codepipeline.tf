# # Arfifact bucket
# resource "aws_s3_bucket" "artifact" {
#   bucket = var.artifact_bucket_name
# }

# resource "aws_s3_bucket_lifecycle_configuration" "artifact_bucket" {
#   bucket = aws_s3_bucket.artifact.id

#   rule {
#     id     = "rule-1"
#     status = "Enabled"
#     expiration {
#       days = 30
#     }
#   }
# }

# # CodeBuild
# resource "aws_codebuild_project" "frontend" {
#   name         = "${var.env}-frontend"
#   service_role = module.codebuild_role.iam_role_arn

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspec.yml"
#   }

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     type            = "LINUX_CONTAINER"
#     compute_type    = "BUILD_GENERAL1_SMALL"
#     image           = "aws/codebuild/standard:5.0"
#     privileged_mode = true

#     environment_variable {
#       name  = "ENV"
#       value = var.env
#     }
#     environment_variable {
#       name  = "AWS_REGION"
#       value = data.aws_region.current.name
#     }
#     environment_variable {
#       name  = "AWS_ACCOUNT_ID"
#       value = data.aws_caller_identity.current.account_id
#     }
#     environment_variable {
#       name  = "REPOSITORY"
#       value = aws_ecr_repository.frontend.name
#     }
#     environment_variable {
#       name  = "CONTAINER_NAME"
#       value = "frontend"
#     }
#     environment_variable {
#       name  = "OUTPUT_JSON"
#       value = var.frontend_build_output_json
#     }
#   }

#   vpc_config {
#     vpc_id = aws_vpc.this.id
#     subnets = [
#       aws_subnet.private_app_1a.id,
#       aws_subnet.private_app_1c.id
#     ]
#     security_group_ids = [
#       aws_security_group.codebuild.id
#     ]
#   }
# }

# # CodePipeline
# resource "aws_codepipeline" "frontend" {
#   name     = "${var.env}-frontend"
#   role_arn = module.codepipeline_role.iam_role_arn

#   stage {
#     name = "Source"

#     action {
#       run_order        = 1
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = 1
#       output_artifacts = ["source_output"]

#       configuration = {
#         ConnectionArn    = var.github_connection_arn
#         FullRepositoryId = var.frontend_full_repository_id
#         BranchName       = var.branch
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       run_order        = 1
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       version          = 1
#       input_artifacts  = ["source_output"]
#       output_artifacts = ["build_output"]

#       configuration = {
#         ProjectName = aws_codebuild_project.frontend.id
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       run_order       = 1
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "ECS"
#       version         = 1
#       input_artifacts = ["build_output"]

#       configuration = {
#         ClusterName = aws_ecs_cluster.this.name
#         ServiceName = aws_ecs_service.frontend.name
#         FileName    = var.frontend_build_output_json
#       }
#     }
#   }

#   artifact_store {
#     location = aws_s3_bucket.artifact.id
#     type     = "S3"
#   }
# }

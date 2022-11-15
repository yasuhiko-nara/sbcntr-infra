resource "aws_ecr_repository" "frontend" {
  name = "${var.env}-frontend"
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1,
          description  = "Keep last 10 tagged images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = [var.env],
            countType     = "imageCountMoreThan",
            countNumber   = 10
          },
          action = {
            type = "expire"
          }
        }
      ]
    }
  )
}

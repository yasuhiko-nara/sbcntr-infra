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
          description  = "Keep last 30 release tagged images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["release"],
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

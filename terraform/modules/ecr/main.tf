terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# ECR Repository for the combined application
resource "aws_ecr_repository" "spacex_app" {
  name                 = "spacex-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Lifecycle policy as a separate resource
resource "aws_ecr_lifecycle_policy" "spacex_app_policy" {
  repository = aws_ecr_repository.spacex_app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# IAM Policy para acceso al repositorio ECR
resource "aws_iam_policy" "ecr_policy" {
  name        = "spacex-app-ecr-policy"
  description = "Policy para acceso a ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [aws_ecr_repository.spacex_app.arn]
      },
      {
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      }
    ]
  })
}

# Outputs para usar en otros módulos
output "repository_url" {
  value = aws_ecr_repository.spacex_app.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.spacex_app.arn
}

output "ecr_policy_arn" {
  value = aws_iam_policy.ecr_policy.arn
}

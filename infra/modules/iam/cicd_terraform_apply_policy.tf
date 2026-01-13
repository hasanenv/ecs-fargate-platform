resource "aws_iam_policy" "terraform_apply" {
  name        = "hasanenv-terraform-apply"
  description = "permissions for ECS deployments, Terraform state, and resource management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:TagResource",
          "ecs:UntagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::hasanenv-tf-state",
          "arn:aws:s3:::hasanenv-tf-state/*"
        ]
      },
      {
        Sid    = "StateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:eu-west-2:727646481331:table/terraform-state-lock"
      },
      {
        Sid    = "Route53Changes"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones"
        ]
        Resource = "*"
      },
      {
        Sid    = "ACMRead"
        Effect = "Allow"
        Action = ["acm:DescribeCertificate"]
        Resource = "*"
      },
      {
        Sid    = "IAMReads"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "LogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMParameterWrites"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:AddTagsToResource",
          "ssm:RemoveTagsFromResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2Read"
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_apply_attach" {
  role       = aws_iam_role.terraform_apply_role.name
  policy_arn = aws_iam_policy.terraform_apply.arn
}

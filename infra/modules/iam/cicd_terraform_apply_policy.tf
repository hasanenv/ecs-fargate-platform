resource "aws_iam_policy" "terraform_apply" {
  name        = "hasanenv-terraform-apply"
  description = "permissions for ECS deployments, Terraform state, and resource management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ##### TERRAFORM CORE READS #####
      {
        Sid    = "TerraformCallerIdentity"
        Effect = "Allow"
        Action = ["sts:GetCallerIdentity"]
        Resource = "*"
      },

      ##### ECS #####
      {
        Sid    = "ECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:TagResource",
          "ecs:UntagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSReads"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions"
        ]
        Resource = "*"
      },

      ##### ECR #####
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRReads"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:ListTagsForResource",
          "ecr:DescribeImages",
          "ecr:ListImages"
        ]
        Resource = "*"
      },

      ##### TERRAFORM STATE #####
      {
        Sid    = "TerraformStateReads"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::hasanenv-tf-state",
          "arn:aws:s3:::hasanenv-tf-state/*"
        ]
      },
      {
        Sid    = "TerraformStateWrites"
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = [
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

      ##### ROUTE53 #####
      {
        Sid    = "Route53Writes"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "*"
      },
      {
        Sid    = "Route53Reads"
        Effect = "Allow"
        Action = [
          "route53:ListResourceRecordSets",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListTagsForResource",
          "route53domains:ListDomains"
        ]
        Resource = "*"
      },

      ##### ACM #####
      {
        Sid    = "ACMReads"
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate"
        ]
        Resource = "*"
      },

      ##### IAM #####
      {
        Sid    = "IAMWrites"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMReads"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListPolicyVersions",
          "iam:ListRoleTags",
          "iam:ListRoles",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      },

      ##### LOGS #####
      {
        Sid    = "LogsWrites"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "LogsReads"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource"
        ]
        Resource = "*"
      },

      ##### SSM #####
      {
        Sid    = "SSMWrites"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:AddTagsToResource",
          "ssm:RemoveTagsFromResource",
          "ssm:LabelParameterVersion"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMReads"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters",
          "ssm:ListTagsForResource"
        ]
        Resource = "*"
      },

      ##### EC2 #####
      {
        Sid    = "EC2Reads"
        Effect = "Allow"
        Action = ["ec2:Describe*"]
        Resource = "*"
      },

      ##### ELB #####
      {
        Sid    = "ELBWrites"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroupAttributes"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELBReads"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:Describe*"
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

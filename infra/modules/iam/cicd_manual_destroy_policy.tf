resource "aws_iam_policy" "manual_destroy_policy" {
  name = "manual-destroy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ec2:DisassociateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DeleteSubnet",
          "ec2:DeleteInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteVpc",
          "ec2:Describe*"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:DeleteParameter",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },

      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "manual_destroy_attach" {
  role       = aws_iam_role.manual_destroy_role.name
  policy_arn = aws_iam_policy.manual_destroy_policy.arn
}
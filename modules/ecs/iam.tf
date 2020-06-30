data "aws_iam_role" "ecs-service-linked-role" {
    name = "AWSServiceRoleForECS"
}

### just for demonstration ###
resource "aws_iam_role" "demo_ecs_role_task_assume" {
  name = "demo_ecsfargate_task_assume"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
  }
  EOF

  tags = {
      IaC = "Sandbox"
  }
}

resource "aws_iam_role_policy" "demo_ecs_task_assume_policy" {
  name = "demo_ecsfargate_task_assume_policy"
  role = aws_iam_role.demo_ecs_role_task_assume.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ssm:GetParameters",
                "secretsmanager:GetSecretValue",
                "kms:Decrypt"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
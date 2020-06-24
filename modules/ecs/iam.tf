// TASKS

data "aws_iam_policy_document" "task_trust_policy_doc" {
  version = "2012-10-17"
  statement {
    sid     = "ECSTaskTrustPolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "demo_task_role" {
  name = "demo_task_role"

  assume_role_policy = data.aws_iam_policy_document.task_trust_policy_doc.json

  tags = {
    IAC  = "Sandbox"
    Name = "demo_task_role"
  }
}

resource "aws_iam_role" "frontend_task_role" {
  name = "frontend_task_role"

  assume_role_policy = data.aws_iam_policy_document.task_trust_policy_doc.json

  tags = {
    IAC  = "Sandbox"
    Name = "frontend_task_role"
  }
}

data "aws_iam_policy_document" "task_permissions_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "CityStockTaskRolePermissionsPolicy"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "task_permissions_policy" {
  name   = "ECSTaskPermissionsPolicy"
  policy = data.aws_iam_policy_document.task_permissions_policy_doc.json

  # tags = {
  #   IAC = "Sandbox"
  #   Name = "ECSTaskPermissionsPolicy"
  # }
}

resource "aws_iam_role_policy_attachment" "demo_task_attachment" {
  role       = aws_iam_role.demo_task_role.name
  policy_arn = aws_iam_policy.task_permissions_policy.arn
}

resource "aws_iam_role_policy_attachment" "frontend_task_attachment" {
  role       = aws_iam_role.frontend_task_role.name
  policy_arn = aws_iam_policy.task_permissions_policy.arn
}

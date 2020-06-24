resource "aws_ecs_cluster" "hello-world" {
  name = "hello-world"
}

resource "aws_ecs_service" "hello-world" {
  name            = "hello-world"
  task_definition = aws_ecs_task_definition.hello-world.arn
  cluster = aws_ecs_cluster.hello-world.id
  launch_type     = "FARGATE"
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.hello-world.arn
    container_name = "hello-world"
    container_port = 80
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.egress-all.id,
      aws_security_group.hello-world-ingress.id
    ]

    subnets = [
      aws_subnet.private.id
    ]
  }
}

resource "aws_cloudwatch_log_group" "hello-world" {
  name = "/ecs/hello-world"
}

resource "aws_ecs_task_definition" "hello-world" {
  family                   = "hello-world"
  container_definitions    = <<-EOT
    [{
      "name": "hello-world",
      "image": "nginx:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "us-east-1",
          "awslogs-group": "/ecs/hello-world",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }]
  EOT

  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.hello-world-task-execution-role.arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
}

resource "aws_iam_role" "hello-world-task-execution-role" {
  name = "hello-world-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs-task-assume-role.json
}

data "aws_iam_policy_document" "ecs-task-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs-task-execution-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role" {
  role = aws_iam_role.hello-world-task-execution-role.name
  policy_arn = data.aws_iam_policy.ecs-task-execution-role.arn
}

resource "aws_lb_target_group" "hello-world" {
  name = "hello-world"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.hello-world-vpc.id

  health_check {
    enabled = true
    path = "/"
  }

  depends_on = [
    aws_alb.hello-world
  ]
}

resource "aws_alb" "hello-world" {
  name = "hello-world-lb"
  internal = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public.id,
    aws_subnet.private.id
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress-all.id
  ]

  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_alb_listener" "hello-world-http" {
  load_balancer_arn = aws_alb.hello-world.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.hello-world.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.hello-world.dns_name}"
}
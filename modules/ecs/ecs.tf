resource "aws_ecs_cluster" "demo" {
  name = "demo_cluster"

  tags = {
    Name = "demo_cluster"
    IAC  = "Sandbox"
  }
}

resource "aws_ecs_task_definition" "demo" {
  family                   = "demo"
  container_definitions    = <<-EOT
    [{
      "name": "demo",
      "image": "nginx:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }]
  EOT
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.demo_task_role.arn
}

# resource "aws_security_group" "demo" {
#   name = "DemoSG"
#   vpc_id = var.vpc_id

#   ingress {
#     from_port = 0
#     to_port = 0
#     protocol = -1
#     security_groups = [aws_security_group.alb-sg.id]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = -1
#   }
# }

resource "aws_ecs_service" "demo" {
  name            = "demo"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.demo.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  # iam_role        = "${aws_iam_role.citystock_service_role.arn}"
  # depends_on      = ["aws_iam_role_policy.citystock_service_role"]

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo.arn
    container_name   = "demo"
    container_port   = 80
  }

  network_configuration {
    subnets         = var.private_subnets[*].id
    security_groups = [aws_security_group.demo.id]
  }
}

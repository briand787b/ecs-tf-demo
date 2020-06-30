resource "aws_ecs_cluster" "sandbox" {
    name = "sandbox"

    tags = {
        IaC = "Sandbox"
    }
}

resource "aws_ecs_service" "go-svc" {
    name = "go-svc"
    cluster = aws_ecs_cluster.sandbox.id
    task_definition = aws_ecs_task_definition.go-svc.arn
    launch_type = "FARGATE"
    desired_count = 1
    
    network_configuration {
        subnets = var.private_subnet_ids
        security_groups = [ var.sg_id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.demo.arn
        container_name = aws_ecs_task_definition.go-svc.family
        container_port = 80
    }
}

resource "aws_ecs_task_definition" "go-svc" {
    family = "go-svc"
    execution_role_arn = aws_iam_role.demo_ecs_role_task_assume.arn
    network_mode = "awsvpc"
    cpu = "256"
    memory = "512"
    requires_compatibilities = ["FARGATE"]
    container_definitions = <<EOT
        [{
            "name": "go-svc",
            "image": "nginx:latest",
            "cpu": 256,
            "memory": 512,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp"
                }
            ]
        }]
    EOT

    tags = {
        Name = "Go-Service Task Definition"
        IaC = "Sandbox"
    }
}
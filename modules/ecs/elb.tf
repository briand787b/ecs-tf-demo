resource "aws_security_group" "demo" {
  name        = "Demo-ECS-ALB-SG"
  description = "SG for Demo ECS ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Demo-ECS-ALB-SG"
    IAC  = "Sandbox"
  }
}

resource "aws_security_group_rule" "allow_all_http" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo.id
}

resource "aws_security_group_rule" "allow_all_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo.id
}

resource "aws_security_group_rule" "allow_outbound" {
  type                     = "egress"
  description              = "ECS ephemeral ports"
  from_port                = 0 # 1024
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.demo.id
  security_group_id        = aws_security_group.demo.id
}

resource "aws_lb" "demo" {
  name               = "Demo-ECS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo.id]
  subnets            = var.public_subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name = "ECS Load Balancer"
    IAC  = "Sandbox"
  }
}

resource "aws_lb_target_group" "demo" {
  name        = "DemoTargetGroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Demo Target Group"
    IAC  = "Sandbox"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.demo]
}

resource "aws_lb_listener" "demo" {
  load_balancer_arn = aws_lb.demo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo.arn
  }
}

output "alb_url" {
  value = "http://${aws_lb.demo.dns_name}"
}

# resource "aws_lb_target_group_attachment" "demo-tg-attachment" {
#   target_group_arn = aws_lb_target_group.demo.arn
#   target_id        = aws_ecs_service.demo.id
#   port             = 80
# }

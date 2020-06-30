resource "aws_alb" "demo" {
  name = "demo-lb"
  internal = false
  load_balancer_type = "application"

  subnets = var.public_subnet_ids

  security_groups = [ var.sg_id ]

  depends_on = [ var.igw ]
}

resource "aws_lb_target_group" "demo" {
  name = "demo"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc_id

  health_check {
    enabled = true
    path = "/"
  }

  depends_on = [
    aws_alb.demo
  ]
}

resource "aws_alb_listener" "demo-http" {
  load_balancer_arn = aws_alb.demo.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.demo.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.demo.dns_name}"
}
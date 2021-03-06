resource "aws_lb" "main" {
  name                       = "website-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.a.id, aws_subnet.b.id]
  enable_deletion_protection = false
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_alb_target_group" "main" {
  name        = "serving-website"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

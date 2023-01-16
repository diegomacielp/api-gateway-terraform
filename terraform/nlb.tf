resource "aws_lb" "lb" {
  name                             = "lb-${var.project_name}"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"
  internal                         = false
  subnets                          = [for s in data.aws_subnet.subnet : s.id]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = var.project_port
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "tg-${var.project_name}"
  port        = var.project_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}
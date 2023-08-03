resource "aws_lb" "exch_server_lb" {
  name               = "web-server-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.exch_security.id]
  subnets            = [aws_subnet.exch_subnet.id, aws_subnet.exch_subnet2.id]
}

resource "aws_lb_target_group" "web_server_target_group" {
  name        = "web-server-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = aws_vpc.exch_vpc.id
}

resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.exch_server_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_target_group.arn
  }
}

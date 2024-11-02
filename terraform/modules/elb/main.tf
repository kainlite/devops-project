resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  target_type = "ip"
  protocol    = "TCP"
  port        = 31113
  vpc_id      = var.vpc_id
}

# WIP
# data "aws_instance" "this" {
#   filter {
#     name   = "tag:Name"
#     values = [""]
#   }
# }
# 
# resource "aws_lb_target_group_attachment" "this" {
#   target_group_arn = aws_lb_target_group.this.arn
#   target_id        = data.aws_instance.this.id
#   port             = 33333
# }

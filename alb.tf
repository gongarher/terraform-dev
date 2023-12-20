resource "aws_lb" "alb" {
  depends_on = [module.vpc]
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.allow_http_anywhere.id]

  tags = merge({Name = var.alb_name}, var.tags)
}

# Listener rule for HTTP traffic on each of the ALBs
resource "aws_lb_listener" "lb_listener_http" {
   load_balancer_arn    = aws_lb.alb.arn
   port                 = "80"
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.service_target_group.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "service_target_group" {
  depends_on = [aws_lb.alb]
  name                 = var.alb_tg_name
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 5
  target_type          = "ip"

  tags = merge({Name = var.alb_tg_name}, var.tags)

}

# ALB SG
resource "aws_security_group" "allow_http_anywhere" {
  name        = "allow_http"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow only HTTP egress traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({Name = "allow_http"}, var.tags)
}
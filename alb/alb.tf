resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_for_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_for_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id =  aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING A TARGET GROUP----------------------
resource "aws_lb_target_group" "jupiter_app_tg" {
  name     = "jupiter-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold = 5
    interval = 30
    matcher = "200,301,302"
    path = "/"
    timeout = 5
    unhealthy_threshold = 2
  }
}

# CREATING APPLICATION LOAD BALANCER--------------------------
resource "aws_lb" "jupiter_app_alb" {
  name               = "jupiter-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_subnet_az_2a, var.public_subnet_az_2b ]

  enable_deletion_protection = false

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-app-alb"
  })
}

# CREATING A LOAD BALANCER LISTENER ON PORT 80----------------
resource "aws_lb_listener" "http_alb_listener" {
  load_balancer_arn = aws_lb.jupiter_app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
  type = "redirect"

  redirect {
    port = 443
    protocol = "HTTPS"
    status_code = "HTTP_301"
  }
  }
}

# CREATING A LOAD BALANCER LISTENER ON PORT 443----------------
resource "aws_lb_listener" "https_alb_listener" {
  load_balancer_arn = aws_lb.jupiter_app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jupiter_app_tg.arn
  }
}

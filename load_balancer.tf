resource "aws_security_group" "load_balancer" {
    name        = "$(var.env_prefix)-load-balancer"
    description = "allow port 80 TCP inbound to ELB"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        description = "http to ELB"
        from_port   = 80
        to_port     = 80
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  

    tags = {
      Name : "$(var.env_prefix)-load-balancer"
    }
}

resource "aws_lb" "main" {
    name               = var.env_prefix
    load_balancer_type = "application"
    security_groups    = [aws_security_group.load_balancer.id]
    subnets            = [aws_subnet.pub-sub-1-a.id,aws_subnet.pub-sub-2-b.id]
    tags     = {
        Name = "${var.env_prefix}-alb"
    }
}

resource "aws_lb_target_group" "main" {
    name     = "${var.env_prefix}-tg"
    port     =  80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc.id  

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

resource "aws_lb_target_group_attachment" "main" {

    target_group_arn = aws_lb_target_group.main.arn
    target_id        = aws_instance.public.id
    port             = 80
}

resource "aws_lb_listener" "main" {
    load_balancer_arn = aws_lb.main.arn
    port              =   "80"
    protocol          =  "HTTP"
    
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
  
}
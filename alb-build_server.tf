## 1 ##
resource "aws_lb" "build-server-alb" {
  name     = "build-server-alb"
  internal = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  subnets = ["${aws_subnet.vpc-1-sub-a.id}", "${aws_subnet.vpc-1-sub-aa.id}"]
  security_groups = ["${aws_security_group.webserver_sg.id}",]
  tags = { Name = "build-server-alb" }
}

## 2##
#resource "aws_lb_listener" "build-server-alb-listner" {
#  load_balancer_arn = aws_lb.build-server-alb.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.build-server-tg.arn
#  }
#}

resource "aws_lb_listener" "build-server-alb-listner" {
  load_balancer_arn = aws_lb.build-server-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  certificate_arn   = "arn:aws:acm:us-east-1:952430311316:certificate/dd923271-af0b-4367-b0c4-fb54556f5420"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.build-server-tg.arn
  }
}

## 3##
resource "aws_lb_target_group" "build-server-tg" {
  
  name        = "build-server-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  #vpc_id      = "${var.vpc_id}"
  vpc_id      = aws_vpc.vpc-1.id
  
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

## 4##
resource "aws_lb_target_group_attachment" "build-server-tg-attachment1" {
  target_group_arn = aws_lb_target_group.build-server-tg.arn
  #target_id        = "${var.instance1_id}"
  target_id        = aws_instance.ec2-vpc_1-pub_sub_a-profile-ex1.id
  port             = 8081
}

#resource "aws_lb_target_group_attachment" "build-server-tg-attachment2" {
#  target_group_arn = aws_lb_target_group.build-server-tg.arn
#  target_id        = aws_instance.ec2-vpc_1-pub_aa_alb_2.id
#  port             = 80
#}


resource "aws_alb" "WPelb" {
  name               = "WPelb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.WordpressELBSG.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_alb_target_group" "WPTG" {
  name     = "WordpressTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.WPvpc.id
  
  lifecycle { create_before_destroy=true }

  health_check {
    path = "/api/1/resolve/default?path=/service/my-service"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "404"  # has to be HTTP 404 or fails
  }

}

#create ALB listener for WP Servers
resource "aws_alb_listener" "WPlistener" {
  default_action {
    target_group_arn = "${aws_alb_target_group.WPTG.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.WPelb.arn}"
  port = 80
  protocol = "HTTP"
}
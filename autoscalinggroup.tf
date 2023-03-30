resource "aws_autoscaling_group" "WPautoscaling" {
  min_size             = var.asg_min
  max_size             = var.asg_max
  desired_capacity     = var.asg_desired
  launch_template {
    id = aws_launch_template.launchtemplate.id
  }
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  target_group_arns    = [aws_alb_target_group.WPTG.arn]
}

# scale up alarm
resource "aws_autoscaling_policy" "cpu-policyscaleup" {
  name = "cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.WPautoscaling.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.up_scaling_adjustment
  cooldown = var.up_cooldown
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaleup" {
  alarm_name = "cpu-alarm"
  alarm_description = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.up_threshold
  dimensions = {
  "AutoScalingGroupName" = "${aws_autoscaling_group.WPautoscaling.name}"
  }
  actions_enabled = var.actions_enabled_up
  alarm_actions = ["${aws_autoscaling_policy.cpu-policyscaleup.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
  name = "example-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.WPautoscaling.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.down_scaling_adjustment
  cooldown = var.down_cooldown
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
  alarm_name = "cpu-alarm-scaledown"
  alarm_description = "cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = var.up_threshold
  dimensions = {
  "AutoScalingGroupName" = "${aws_autoscaling_group.WPautoscaling.name}"
  }
  actions_enabled = var.actions_enabled_up
  alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}
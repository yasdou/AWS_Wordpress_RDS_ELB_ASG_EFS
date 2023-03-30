# Launch Template Resource
resource "aws_launch_template" "launchtemplate" {
  name = "launchtemplate"
  image_id = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.WordpressSGprivateinstances.id]
  key_name = var.ami_key_pair_name
  user_data = base64encode(templatefile("${path.module}/wordpress.sh", local.vars))
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Wordpresslaunchtemplate"
    }
  }
}
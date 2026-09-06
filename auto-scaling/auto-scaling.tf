resource "aws_security_group" "jupiter_server_sg" {
  name        = "jupiter-server-sg"
  description = "Allow SSH, HTTP"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupier-server-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_for_jupiter_server" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING A LAUNCH TEMPLATE FOR JUPITER APPLICATION-------------------------
resource "aws_launch_template" "jupiter_app_lt" {
  name_prefix = "jupiter-app-lt"
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("${path.module}/../scripts/jupiter-app-deployment.sh"))
    
    network_interfaces {
      associate_public_ip_address = true
      security_groups =[aws_security_group.jupiter_server_sg.id] 
    }
}

# CREATING AUTO-SCALING GROUP--------------------------
resource "aws_autoscaling_group" "jupiter_app_asg" {
  name                      = "jupiter-app-asg"
  max_size                  = 8
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = false
  target_group_arns = var.jupiter_app_tg_arn
  vpc_zone_identifier       = [var.public_subnet_az_2a, var.public_subnet_az_2b]

launch_template {
  id = aws_launch_template.jupiter_app_lt.id
  version = "$Latest"
 }
}
resource "aws_security_group" "bastion_host_sg" {
  name        = "bastion-host-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_for_bastion_host" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING A BASTION HOST-----------------------------------------
resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.public_subnet_az_2a
  security_groups = [aws_security_group.bastion_host_sg.id]
  associate_public_ip_address = true

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
  })
}

# CREATING PRIVATE SECURITY GROUP----------------------------------------------------
resource "aws_security_group" "private_server_sg" {
  name        = "private-server-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_for_private_server" {
  security_group_id = aws_security_group.private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_private_servers" {
  security_group_id = aws_security_group.private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING PRIVATE SERVER IN AZ 2A---------------------------------------------------
resource "aws_instance" "private_server_az_2a" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.private_subnet_az_2a
  security_groups = [aws_security_group.private_server_sg.id]
  associate_public_ip_address = false

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-2a"
  })
}

# CREATING PRIVATE SERVER IN AZ 2B---------------------------------------------------
resource "aws_instance" "private_server_az_2b" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.private_subnet_az_2b
  security_groups = [aws_security_group.private_server_sg.id]
  associate_public_ip_address = false

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-2b"
  })
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.db_subnet_az_2a, var.db_subnet_az_2b]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnets-group"
  })
  }

  # CREATING RDS SECURITY GROUP----------------------------------------------
  resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow DB traffic for mysql database"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_traffic" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING MYSQL RDS--------------------------------------------
data "aws_secretsmanager_secret" "db_password" {
  name = "mysql_db_cred"  # name of the secretes in AWS
}

data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

# CREATING MYSQL DB INSTANCE---------------------------------------
resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["mysql_username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["mysql_password"]
  parameter_group_name = var.parameter_group_name
  publicly_accessible  = false 
  skip_final_snapshot  = true
  multi_az             = true
  storage_type         = "gp2"
  db_subnet_group_name =  aws_db_subnet_group.db_subnet_group.id 
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  iam_database_authentication_enabled = true
} 
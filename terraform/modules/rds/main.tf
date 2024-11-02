resource "aws_db_instance" "this" {
  allocated_storage      = var.db_size
  identifier             = var.instance_name
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class # "db.t3.micro"
  username               = var.db_username       # "postgres"
  password               = random_password.password.result
  parameter_group_name   = aws_db_parameter_group.this.name
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = var.tags
}

resource "aws_db_subnet_group" "this" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.instance_name}-pg"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

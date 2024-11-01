resource "aws_db_instance" "this" {
  allocated_storage    = var.db_size
  db_name              = var.db_name
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = var.db_instance_class # "db.t3.micro"
  username             = var.db_username       # "postgres"
  password             = random_password.password.result
  parameter_group_name = "default.postgres17.0"
  skip_final_snapshot  = true
  tags                 = var.tags
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

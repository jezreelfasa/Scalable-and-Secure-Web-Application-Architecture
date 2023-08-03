# Create AWS RDS instance
resource "aws_db_instance" "web-app-db" {
  identifier             = "web-app-db"
  engine                 = "MYSQL"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = "admin"
  password               = "adminadmin"
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.exch_security.id]
  db_subnet_group_name   = aws_db_subnet_group.sub-group.name
}

# Creation of subnet_group for the RDS database 
resource "aws_db_subnet_group" "sub-group" {
  name        = "sub-group"
  description = "Subnet group for the RDS database for the web app configuration"
  subnet_ids = [
    aws_subnet.exch_subnet.id,
    aws_subnet.exch_subnet2.id,
    aws_subnet.exch_subnet3.id
  ]
}

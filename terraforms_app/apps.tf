# Here, the provider block for AWS is defined
provider "aws" {
  access_key = "AKIAZYXPFPWSVDIFSDGG"
  secret_key = "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"
  region     = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "app-tf-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "app-tf-Vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app-tf-vpc.id

  tags = {
    Name = "prod-ig"
  }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.app-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.app-tf-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod-Subnet1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.app-tf-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod-Subnet2"
  }
}

resource "aws_subnet" "subnet-3" {
  vpc_id            = aws_vpc.app-tf-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod-Subnet3"
  }
}

resource "aws_route_table_association" "tf-route" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.app-tf-vpc.id

  ingress {
    description = "MYSQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}


resource "aws_eip" "one" {
  domain                    = "vpc"
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# Creation of load balancer
resource "aws_lb" "web-app" {
  name               = "app-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  security_groups    = [aws_security_group.allow_web.id]
}

# LB listener
resource "aws_lb_target_group" "web-app" {
  name     = "web-app-lb"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.app-tf-vpc.id
}

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
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  db_subnet_group_name   = aws_db_subnet_group.sub-group.name
}

# Creation of subnet_group for the RDS database 
resource "aws_db_subnet_group" "sub-group" {
  name        = "sub-group"
  description = "Subnet group for the RDS database for the web app configuration"
  subnet_ids = [
    aws_subnet.subnet-1.id,
    aws_subnet.subnet-2.id,
    aws_subnet.subnet-3.id
  ]
}

# Creating auto scaling group
resource "aws_launch_configuration" "web-app-config" {
  name_prefix     = "app-lc-"
  image_id        = "ami-053b0d53c279acc90"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_web.id]
  key_name        = "web-app-key"
  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_autoscaling_group" "web-app-instance" {
  name                 = "app-asg"
  launch_configuration = aws_launch_configuration.web-app-config.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  health_check_type    = "EC2"
  vpc_zone_identifier  = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  target_group_arns    = [aws_lb_target_group.web-app.arn]
}

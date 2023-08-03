#Creation of security group
resource "aws_security_group" "exch_security" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.exch_vpc.id

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

#Creation of network interface
resource "aws_network_interface" "exch_interface" {
  subnet_id       = aws_subnet.exch_subnet.id
  private_ips     = ["10.0.1.55"]
  security_groups = [aws_security_group.exch_security.id]
}


resource "aws_eip" "one" {
  domain                    = "vpc"
  associate_with_private_ip = "10.0.1.55"
  depends_on                = [aws_internet_gateway.exch_gateway]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}


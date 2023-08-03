#Creation of VPC
resource "aws_vpc" "exch_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"


}


#Creation of subnet for Vpc
resource "aws_subnet" "exch_subnet" {
  vpc_id            = aws_vpc.exch_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"


  tags = {
    name = "Exchange_Subnet"

  }

}


resource "aws_subnet" "exch_subnet2" {
  vpc_id            = aws_vpc.exch_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"


  tags = {
    name = "Exchange_Subnet2"

  }

}


resource "aws_subnet" "exch_subnet3" {
  vpc_id            = aws_vpc.exch_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1b"


  tags = {
    name = "Exchange_Subnet3"

  }

}


#Creation of internet gateway
resource "aws_internet_gateway" "exch_gateway" {
  vpc_id = aws_vpc.exch_vpc.id



  tags = {
    name = "Exchange_Gateway"
  }
}

#Creation of route table
resource "aws_route_table" "exch_route_table" {
  vpc_id = aws_vpc.exch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.exch_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.exch_gateway.id
  }
}


#Create route table association
resource "aws_route_table_association" "exch_asociation" {
  subnet_id      = aws_subnet.exch_subnet.id
  route_table_id = aws_route_table.exch_route_table.id
}







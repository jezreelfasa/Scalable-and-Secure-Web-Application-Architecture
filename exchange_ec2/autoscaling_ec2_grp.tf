provider "aws" {
  access_key = ""
  secret_key = ""
}






resource "aws_launch_configuration" "exch-config" {
  name_prefix     = "exchange-rates_template"
  image_id        = "ami-053b0d53c279acc90"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.exch_security.id]
  key_name        = "web_app_key"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web-app-instance" {
  name                 = "app-asg"
  launch_configuration = aws_launch_configuration.exch-config.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  health_check_type    = "EC2"
  vpc_zone_identifier  = [aws_subnet.exch_subnet.id, aws_subnet.exch_subnet2.id, aws_subnet.exch_subnet.id]
  target_group_arns    = [aws_lb_target_group.web_server_target_group.arn]
}











/*provider "aws" {
  region     = aws_launch_configuration.region.name
  access_key = "AKIAZYXPFPWSYTYNMTLO"
  secret_key = "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"
}


resource "aws_instance" "exch_web_server" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "exchange_keys"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.exch_interface.id
  }

  user_data = <<-EOF
            #! /bin/bash
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo bash -c 'Welcome to the exchange server"
            cd /home/ubuntu
            sudo mkdir python-json-env
            cd python-json-env
            sudo touch exchange.json

            EOF
}

*/

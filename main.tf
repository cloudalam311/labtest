resource "aws_ebs_volume" "my_volume" {
  availability_zone = "us-east-1a"
  size              = 1
  type              = "gp2"
}

resource "aws_instance" "webserver" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = ["${aws_security_group.webserver_security_group.id}"]
  tags = {
    Name = "Webserver"
  }
  key_name  = "my-labtestkey"
  user_data = <<-EOF
    #!/bin/bash -xe
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    sudo apt update -y 
    sudo apt install php -y
    sudo systemctl stop apache2
    sudo apt install nginx -y
    sudo su -c "/bin/echo 'Thank You' >/var/www/html/index.html"
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdf" # Use the correct device name (e.g., "/dev/xvdf")
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.webserver.id
}

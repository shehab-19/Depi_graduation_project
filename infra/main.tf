resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = var.vpc-name
  }
}



resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-subnet-cidr_block
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}



resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-subnet-cidr_block2
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.128.0/20"
  availability_zone       = var.az
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.144.0/20"
  availability_zone       = var.az2
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}



resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw-name
  }
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {

    Name = var.public-rtb-name
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "web_sg" {
  name        = "web_server-sg"
  description = "Security group for web app"
  vpc_id      = aws_vpc.main.id


  # web access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server-security-group"
  }

}



resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("~/.ssh/deployer.pub")
}





resource "aws_instance" "web_server" {
  ami                    = var.ami
  instance_type          = var.t2-instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  depends_on             = [aws_db_instance.default]
  tags = {
    Name = "web_server"
  }

}

resource "null_resource" "setup_environment" {
  depends_on = [aws_instance.web_server]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.web_server.public_ip
    private_key = file("~/.ssh/deployer")
  }

  provisioner "file" {
    source      = "../QRCode_APP_Chart"
    destination = "/home/ubuntu/"
  }
  
  provisioner "file" {
    source      = "continue_installation.sh"
    destination = "/home/ubuntu/continue_installation.sh"
  }

  provisioner "file" {
    source      = "argocd.yaml"
    destination = "/home/ubuntu/argocd.yaml"
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'export DB_HOST=${split(":", aws_db_instance.default.endpoint )[0]}' >> ~/.bashrc",
      "echo 'export DB_USER=${data.aws_ssm_parameter.db-username.value}' >> ~/.bashrc",
      "echo 'export DB_NAME=${data.aws_ssm_parameter.db-name.value}' >> ~/.bashrc",
      "echo 'export DB_PASSWORD=${data.aws_ssm_parameter.db-password.value}' >> ~/.bashrc",
      "echo 'export URL=${aws_instance.web_server.public_dns}' >> ~/.bashrc",
      "source /home/ubuntu/.bashrc"
    ]
  }

  provisioner "remote-exec" {
    script = "./installation.sh"
  }

}




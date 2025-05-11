

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
    source      = "./scripts/continue_installation.sh" ##
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
    script = "./scripts/installation.sh"##
  }

}




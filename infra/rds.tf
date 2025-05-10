data "aws_ssm_parameter" "db-password" {
  name = "/qr/dbpass"
}
data "aws_ssm_parameter" "db-username" {
  name = "/qr/dbuser"
}

data "aws_ssm_parameter" "db-name" {
  name = "/qr/dbname"
}





# resource "aws_security_group" "db_sg" {
#   name        = "db-sg"
#   description = "Security group for database"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port       = 1433
#     to_port         = 1433
#     protocol        = "tcp"
#     security_groups = [aws_security_group.web_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "db-security-group"
#   }

# }



# resource "aws_db_instance" "default" {
#   allocated_storage = 20
#   # db_name              = data.aws_ssm_parameter.db-name.value
#   identifier           = "database01"
#   db_subnet_group_name = aws_db_subnet_group.subnet_group.name
#   engine               = "sqlserver-ex"
#   engine_version       = "15.00.4430.1.v1"
#   instance_class       = "db.t3.micro"
#   username             = data.aws_ssm_parameter.db-username.value
#   password             = data.aws_ssm_parameter.db-password.value
#   # parameter_group_name = "default.mysql8.0"
#   multi_az            = false
#   storage_type        = "gp2"
#   storage_encrypted   = true
#   deletion_protection = false
#   skip_final_snapshot = true
#   publicly_accessible = false

#   vpc_security_group_ids = [aws_security_group.db_sg.id]

#   tags = {
#     Name = "mydb"
#   }
# }



# resource "aws_db_subnet_group" "subnet_group" {
#   name       = "mydb-subnet-group"
#   subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
#   tags = {
#     Name = "mydb-subnet-group"
#   }
# }


# output "db-endpoint" {
#   value = aws_db_instance.default.endpoint
# }

# output "server-ip" {
#   value = aws_instance.controlplane.public_ip
# }

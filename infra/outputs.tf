output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "server_ip" {
  value = aws_instance.web_server.public_ip
}

output "server_dns"{
    value = aws_instance.web_server.public_dns
}
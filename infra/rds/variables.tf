variable "db_name" {}
variable "db_identifier" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}

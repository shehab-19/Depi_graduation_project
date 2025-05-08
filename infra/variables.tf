variable "az" {
    type        = string
    default     = "us-east-1a"
}

# variable "az2" {
#     type        = string
#     default     = "us-east-1a"
# }

variable "public-subnet-cidr_block" {
    type = string
    default = "10.0.0.0/18"

}

variable "public-subnet-cidr_block2" {
    type = string
    default = "10.0.64.0/18"

}



variable "public-rtb-name" {
    default = "public-rtb"
}

variable "private-rtb-name" {
    default = "private-rtb"
}

variable "igw-name" {
  default = "custom-igw"
}

variable "vpc-name" {
    default = "my-vpc-2"
}


variable "ami" {
    default = "ami-053b0d53c279acc90"  # Ubuntu 22.04 LTS AMI in us-east-1
    type    = string
}

variable "t2-instance_type" {
    default = "t2.medium"
    type    = string
}

variable "db-name" {
  default = "bookstore"
}

variable "db-identifier" {
  default = "database01"
}
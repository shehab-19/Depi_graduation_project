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

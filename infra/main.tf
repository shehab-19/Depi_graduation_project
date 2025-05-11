module "network" {
  source               = "./modules/network"
  ami           = "ami-04b4f1a9cf54c11d0"# Ubuntu 24.04 LTS AMI in us-east-1
  instance_type = "t2.medium"
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "my-vpc-2"
  public_subnet_cidr1  = "10.0.0.0/18"
  public_subnet_cidr2  = "10.0.64.0/18"
  private_subnet_cidr1 = "10.0.128.0/20"
  private_subnet_cidr2 = "10.0.144.0/20"
  az1                  = "us-east-1a"
  az2                  = "us-east-1b"
  igw_name             = "custom-igw"
  public_rtb_name      = "public-rtb"
}


module "rds" {
  source            = "./modules/rds"
  db_name           = "bookstore"
  db_identifier     = "database01"
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}
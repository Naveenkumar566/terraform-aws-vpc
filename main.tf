resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id #association

  tags = local.igw_final_tags
  
} 

resource "aws_subnet" "main" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id  
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = var.public_subnet_tags
}
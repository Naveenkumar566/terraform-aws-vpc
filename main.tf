resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

#IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id #association

  tags = local.igw_final_tags
  
} 

#subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id  
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    # roboshop=dev-public-us-east-1a
    {
      Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subnet_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id  
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    # roboshop=dev-private-us-east-1a
    {
      Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    },
    var.private_subnet_tags
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id  
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    # roboshop=dev-database-us-east-1a
    {
      Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    },
    var.database_subnet_tags
  )
}


#route tables 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    # roboshop=dev-public
    {
      Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    # roboshop=dev-private
    {
      Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    # roboshop=dev-database
    {
      Name = "${var.project}-${var.environment}-database"
    },
    var.database_route_table_tags
  )
}

#Routes
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge(
    local.common_tags,
    # roboshop=dev-nat
    {
      Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )
}

#NAT gateways
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id #This going to be created in US-east-1a AZ zone and [0] shows the postion.

  tags = merge(
    local.common_tags,
    # roboshop=dev
    {
      Name = "${var.project}-${var.environment}"
    },
    var.aws_nat_gateway_tags
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#Associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1:0     #Creating VPC depends on variable if it is 1 it creates, If it is 0 itbwill not create
  
  #peer_owner_id = var.peer_owner_id        This option can be used only when we are peering VPC with other account.
  
  peer_vpc_id   = data.aws_vpc.default.id    #this is VPC peering id which is accepting the peering. : Acceptor


  vpc_id        = aws_vpc.main.id            #requestor id

  auto_accept   = true                       #if it is in same region 

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

   tags = merge(
    local.common_tags,
    # roboshop=dev
    {
      Name = "${var.project}-${var.environment}-default"
    }
  )
}



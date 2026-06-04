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

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1:0                                          #if user says it is not required then it will not be created.
  route_table_id            = aws_route_table.public.id                          # peering with public subnet id
  destination_cidr_block    = data.aws_vpc.default.cidr_block                    #from default VPC,cidr_block attribute is exported
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id    #This shows the peering is configured from default vpc peering connection 
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1:0                               
  route_table_id            = aws_route_table.private.id               
  destination_cidr_block    = data.aws_vpc.default.cidr_block          
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id 
}
  

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1:0                               
  route_table_id            = aws_route_table.database.id                
  destination_cidr_block    = data.aws_vpc.default.cidr_block          
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id    
}

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1:0                                 
  route_table_id            = data.aws_route_table.default.id                
  destination_cidr_block    = var.vpc_cidr                             
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id   
}

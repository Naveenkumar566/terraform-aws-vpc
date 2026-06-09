variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "project" {
  type    = string
  default = "roboshop"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "igw_tags" {
  type = map
  default = {}
}

variable "public_subnet_cidrs" {
  type = list
  default = ["10.1.4.0/24", "10.1.6.0/24"]
}

variable "public_subnet_tags" {
  type = map
  default = {}
}

variable "private_subnet_cidrs" {
  type = list
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "private_subnet_tags" {
  type = map
  default = {}
}

variable "database_subnet_cidrs" {
  type = list
  default = ["10.1.21.0/24", "10.1.22.0/24"]
}

variable "database_subnet_tags" {
  type = map
  default = {}
}

variable "public_route_table_tags" {
  type = map
  default = {}
}

variable "private_route_table_tags" {
  type = map
  default = {}
}

variable "database_route_table_tags" {
  type = map
  default = {}
}

variable "eip_tags" {
  type = map
  default = {}
}

variable "aws_nat_gateway_tags" {
  type = map
  default = {}
}

 variable "is_peering_required" {
   type = bool
  default = false
 }


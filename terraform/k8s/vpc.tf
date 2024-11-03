provider "aws" {
  region = "ap-northeast-2"
  shared_credentials_files = [".aws/credentials"]
  profile = "eks"
}

locals {
  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_private_subnets" {
  count      = length(local.private_subnets)
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "eks-vpc-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "eks_public_subnets" {
  count      = length(local.public_subnets)
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = local.public_subnets[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-vpc-public-subnet-${count.index}"
  }
}

resource "aws_eip" "lb" {
  domain = "vpc"

  tags = {
    Name = "eks-eip-lb"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.lb.id
  subnet_id = aws_subnet.eks_public_subnets[0].id

  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count = length(aws_subnet.eks_public_subnets)

  subnet_id      = aws_subnet.eks_public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "b" {
  count = length(aws_subnet.eks_private_subnets)

  subnet_id      = aws_subnet.eks_private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

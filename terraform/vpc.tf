/** VPC with 2 public subnets across 2 AZs for high availability */
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}

# connects the VPC to the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-${count.index + 1}" })
}

# route all outbound traffic through the internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-rt-public" })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

/** vpc for EKS */
/**
  EKS subnets — 3 subnets, one per AZ (a, b, c)
  10.0.10.0/24 → ap-southeast-1a
  10.0.11.0/24 → ap-southeast-1b
  10.0.12.0/24 → ap-southeast-1c
*/
resource "aws_subnet" "eks" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  availability_zone       = local.eks_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                             = "${local.name_prefix}-eks-${count.index + 1}"
    "kubernetes.io/cluster/${local.name_prefix}-eks" = "owned"
  })
}

resource "aws_route_table_association" "eks" {
  count          = 3
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.public.id
}

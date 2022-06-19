resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.workspace}-pub - 10.0.${count.index}.0 - ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.workspace}-priv - 10.0.${count.index + 2}.0 - ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "db_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.${count.index + 4}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.workspace}-privDB - 10.0.${count.index + 4}.0 - ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "${var.project_name}-${var.workspace}-project-igw"
  }
}

resource "aws_eip" "nat-gw-eip" {
  count = 2
  vpc   = true

  tags = {
    Name = "${var.project_name}-${var.workspace}-EIP-${count.index}"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count         = 2
  allocation_id = aws_eip.nat-gw-eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "project - gw NAT - ${count.index}"
  }

  depends_on = [aws_internet_gateway.project_igw]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-public-route-table"
  }
}


resource "aws_route_table" "private_route_table" {
  count  = 2
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-private-route-table-${count.index}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_igw.id
}

resource "aws_route" "private_route" {
  count                  = 2
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw[count.index].id
}


resource "aws_route_table_association" "public-associations" {
  count          = 2
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private-associations" {
  count          = 2
  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

#just so main rt is a private one and not the default
resource "aws_main_route_table_association" "main-route-table" {
  vpc_id         = aws_vpc.project_vpc.id
  route_table_id = aws_route_table.private_route_table[0].id
}

resource "aws_key_pair" "awstp_auth" {
  key_name   = "awstpkey"
  public_key = file("~/.ssh/${var.ssh_public_key}")
}


resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.WPvpc.id
  cidr_block = var.cidr_privat1
  availability_zone = "us-west-2a"
  tags = {
    Name = "Private subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.WPvpc.id
  cidr_block = var.cidr_privat2
  availability_zone = "us-west-2b"
  tags = {
    Name = "Private subnet 2"
  }
}

# Create a public subnet for the bastion host
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.WPvpc.id
  availability_zone = "us-west-2a"
  cidr_block = var.cidr_public1
  tags = {
    Name = "public-subnet-1"
  }
}

# Create a second public subnet 
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.WPvpc.id
  cidr_block = var.cidr_public2
  availability_zone = "us-west-2b"
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_database_subnet_1" {
  vpc_id     = aws_vpc.WPvpc.id
  cidr_block = var.cidr_db_privat1
  availability_zone = "us-west-2a"
  tags = {
    Name = "Private database subnet 1"
  }
}

resource "aws_subnet" "private_database_subnet_2" {
  vpc_id     = aws_vpc.WPvpc.id
  cidr_block = var.cidr_db_privat2
  availability_zone = "us-west-2b"
  tags = {
    Name = "Private database subnet 2"
  }
}

resource "aws_db_subnet_group" "DBSubnetGroup" {
  name       = "subnetgroupdb"
  subnet_ids = [aws_subnet.private_database_subnet_1.id, aws_subnet.private_database_subnet_2.id]

  tags = {
    Name = "WP DB subnet group"
  }
}
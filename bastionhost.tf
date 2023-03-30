#create a bastion host in a public subnet to access your Wordpress instances 
#get IP adress of your machine
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Create a new security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.WPvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.*.body[0])}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-sg"
  }
}

# Create a new instance for the bastion host
resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name
  subnet_id     = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }

  # Associate a public IP address with the instance
  associate_public_ip_address = true
}


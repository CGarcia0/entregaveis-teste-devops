module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_security_group" "eks_security_group" {
  name        = "${var.vpc_name}-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-eks-sg"
  }
}

resource "aws_security_group" "nat_sg" {
  name        = "${var.vpc_name}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-nat-sg"
  }
}

resource "aws_instance" "nat_instance" {
  ami                        = "ami-0dc2d3e4c0f9ebd18" # AMI for NAT instance
  instance_type              = "t3.micro"
  subnet_id                  = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
  source_dest_check          = false
  key_name                   = var.key_name

  security_groups = [aws_security_group.nat_sg.id] # Use o ID do grupo de segurança

  user_data = <<-EOF
              #!/bin/bash
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              sysctl -p
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              iptables-save > /etc/iptables/rules.v4
              EOF

  tags = {
    Name = "${var.vpc_name}-nat-instance"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = element(module.vpc.private_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.vpc_name}-jenkins-sg"
  description = "Security group for Jenkins instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-jenkins-sg"
  }
}

# EC2 Instance for Jenkins
resource "aws_instance" "jenkins_instance" {
  ami                    = var.ami_id
  instance_type          = "t3.small"
  subnet_id              = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk11 -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "jenkins_instance"
  }
}

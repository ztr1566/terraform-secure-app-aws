resource "aws_security_group" "proxy" {
  name        = "proxy-sg"
  description = "Allow HTTP and SSH traffic to proxy instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proxy-sg"
  }
}

resource "aws_security_group" "backend" {
  name        = "backend-sg"
  description = "Allow traffic from internal LB and bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from Proxy SG for provisioning"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy.id]
  }

  ingress {
    description = "Allow traffic from the private subnets for ALB health checks and traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

resource "aws_security_group" "internal_alb" {
  name        = "internal-alb-sg"
  description = "Allow traffic from proxy instances to internal alb"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from Proxy SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internal-alb-sg"
  }
}

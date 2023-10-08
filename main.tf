provider "aws" {
  region  = "eu-west-3"
  profile = "nuumfactory-student"
}

terraform {
  backend "s3" {
    bucket  = "nuumfactory-terraform-backend"
    key     = "terraform-XX-dev.tfstate"
    region  = "eu-west-3"
    profile = "nuumfactory-student"
  }
}

resource "aws_security_group" "lb" {
  name   = "nuumfactory-${var.environnement}-lb-sg-${var.digit}"
  vpc_id = "vpc-0f499c2678b9734d6"

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "nuumfactory-${var.environnement}-lb-sg-${var.digit}"
  }
}

resource "aws_security_group" "serveur_web" {
  name   = "nuumfactory-${var.environnement}-ec2-sg-${var.digit}"
  vpc_id = "vpc-0f499c2678b9734d6"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.65.42.76/32"] # Remplacer par votre adresse IP publique
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nuumfactory-${var.environnement}-ec2-sg-${var.digit}"
  }
}

resource "aws_security_group" "db" {
  name   = "nuumfactory-${var.environnement}-db-sg-${var.digit}"
  vpc_id = "vpc-0f499c2678b9734d6"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.serveur_web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nuumfactory-${var.environnement}-db-sg-${var.digit}"
  }
}

variable "vpc" {
  type = string
}

variable "environnement" {
  type = string
}

variable "digit" {
  type = string
}

variable "elb_subnets" {
  type = list(string)
}

variable "ec2_subnet" {
  type = string
}

variable "ec2_type" {
  type = string
}

locals {
  elb_sg_name = "nuumfactory-${var.environnement}-lb-${var.digit}"
  ec2_sg_name = "nuumfactory-${var.environnement}-ec2-${var.digit}"
  db_sg_name  = "nuumfactory-${var.environnement}-elb-${var.digit}"
}
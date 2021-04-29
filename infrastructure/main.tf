terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_ecs_cluster" "fargate_cluster" {
  name               = "fargate-cluster"
  capacity_providers = ["FARGATE"]
}


resource "aws_ecs_service" "nextjs_fargate" {
  name          = "nextjs-fargate"
  cluster       = aws_ecs_cluster.fargate_cluster.id
  desired_count = 1

  deployment_controller {
    type = "EXTERNAL"
  }
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  }
}

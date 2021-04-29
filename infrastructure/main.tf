terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
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

resource "aws_ecs_cluster" "fargate_cluster" {
  name               = "fargate-cluster"
  capacity_providers = ["FARGATE"]
}


resource "aws_ecs_service" "nextjs_fargate" {
  name          = "nextjs-fargate"
  cluster       = aws_ecs_cluster.fargate_cluster.id
  desired_count = 1
  iam_role      = aws_iam_role.ecs_task_execution_role.arn

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "nextjs-website"
    container_port   = 3000
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  }
}

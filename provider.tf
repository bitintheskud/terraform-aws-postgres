data "aws_availability_zones" "available" {
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
  }
}

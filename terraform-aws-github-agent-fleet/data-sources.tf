data "aws_vpc" "okera_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnets" "okera_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.okera_vpc.id]
  }
  tags = {
    Name = "Cerebro Internal Pvt"
  }
}

data "aws_security_groups" "okera_security_group" {
  tags = {
    Name = "Default SG - Always use this"
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.okera_vpc.id]
  }
}
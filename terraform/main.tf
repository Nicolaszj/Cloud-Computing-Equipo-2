data "aws_vpc" "base" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "publica" {
  vpc_id = data.aws_vpc.base.id

  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

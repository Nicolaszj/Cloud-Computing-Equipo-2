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


resource "aws_sqs_queue" "pedidos" {
  name                      = "${var.prefix}-pedidos"
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  sqs_managed_sse_enabled   = true
}
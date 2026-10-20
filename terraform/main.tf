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


resource "aws_iam_role" "productor" {
  name = "${var.prefix}-role-productor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy" "enviar_a_cola" {
  name = "${var.prefix}-policy-sqs-send"
  role = aws_iam_role.productor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "SoloEnviarALaColaDelReto"
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.pedidos.arn
    }]
  })
}


resource "aws_iam_instance_profile" "productor" {
  name = "${var.prefix}-profile-productor"
  role = aws_iam_role.productor.name
}

resource "aws_security_group" "productor" {
  name        = "${var.prefix}-sg-productor"
  description = "Sin entradas, solo HTTPS de salida"
  vpc_id      = data.aws_vpc.base.id

  egress {
    description = "HTTPS hacia el endpoint de SQS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-sg-productor"
  }
}

resource "aws_instance" "productor" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.publica.id
  vpc_security_group_ids      = [aws_security_group.productor.id]
  iam_instance_profile        = aws_iam_instance_profile.productor.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    queue_url = aws_sqs_queue.pedidos.url
    region    = var.aws_region
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.prefix}-ec2-productor"
  }
}
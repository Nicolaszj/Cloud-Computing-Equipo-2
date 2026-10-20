output "vpc_reutilizada" {
  description = "VPC existente leida con data source"
  value       = "${var.vpc_name} (${data.aws_vpc.base.id})"
}

output "subnet_id" {
  description = "Subnet publica donde corre la EC2"
  value       = data.aws_subnet.publica.id
}

output "ami_id" {
  description = "AMI de Amazon Linux 2023 que encontro el data source"
  value       = data.aws_ami.al2023.id
}

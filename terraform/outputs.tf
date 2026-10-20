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

output "queue_url" {
  description = "URL de la cola del reto"
  value       = aws_sqs_queue.pedidos.url
}

output "queue_arn" {
  description = "ARN de la cola, el unico recurso que el role puede usar"
  value       = aws_sqs_queue.pedidos.arn
}

output "instance_id" {
  description = "id EC2 productora"
  value       = aws_instance.productor.id
}

output "role_name" {
  description = "IAM Role de la EC2"
  value       = aws_iam_role.productor.name
}

output "security_group_id" {
  description = "Security Group sin reglas de entrada"
  value       = aws_security_group.productor.id
}

output "comando_prueba" {
  description = "Comando para leer el pedido que envio la EC2"
  value       = "aws sqs receive-message --queue-url ${aws_sqs_queue.pedidos.url} --region ${var.aws_region} --wait-time-seconds 10 --query 'Messages[].Body' --output text"
}
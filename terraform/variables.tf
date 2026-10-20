variable "aws_region" {
  description = "Region donde se despliega el slice"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefijo propio del reto"
  type        = string
  default     = "cafeluna-tf"
}

variable "equipo" {
  description = "Numero del Equipo"
  type        = string
  default     = "2"
}

variable "vpc_name" {
  description = "Tag Name de la VPC existente"
  type        = string
}

variable "subnet_name" {
  description = "Tag Name de una subnet publica existente dentro de la VPC"
  type        = string
}

variable "instance_type" {
  description = "Tipo de EC2 productora"
  type        = string
  default     = "t3.micro"
}

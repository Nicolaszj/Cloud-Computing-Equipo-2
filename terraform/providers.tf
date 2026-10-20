provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Proyecto   = "CafeLuna"
      Equipo     = var.equipo
      Componente = "reto-terraform"
      ManagedBy  = "terraform"
    }
  }
}

# Reto Terraform: Digital Café Luna (Equipo 2)

Slice de infraestructura reproducible con Terraform. Una EC2 productora envía un pedido de prueba a una cola SQS usando un IAM Role de mínimo privilegio. La red se reutiliza mediante data sources: Terraform no la crea, no la modifica y no la destruye.

## Arquitectura del slice

```
EC2 cafeluna-tf-ec2-productor ── IAM Role (solo sqs:SendMessage) --> SQS cafeluna-tf-pedidos
        │
        └── VPC existente cafeluna-vpc / cafeluna-subnet-publica-a  (data source, fuera del state administrado)
```

| Recurso | Nombre | Cómo lo maneja Terraform |
|---|---|---|
| VPC y subnet | cafeluna-vpc / cafeluna-subnet-publica-a | `data` (solo lectura) |
| AMI | Amazon Linux 2023 más reciente | `data` (solo lectura) |
| Cola SQS Standard | cafeluna-tf-pedidos | `resource` (cifrado SSE-SQS) |
| IAM Role + policy inline | cafeluna-tf-role-productor | `resource` (solo `sqs:SendMessage` sobre el ARN de la cola) |
| Instance Profile | cafeluna-tf-profile-productor | `resource` |
| Security Group | cafeluna-tf-sg-productor | `resource` (sin entradas; salida 443) |
| EC2 t3.micro | cafeluna-tf-ec2-productor | `resource` (IMDSv2 obligatorio, sin key pair) |

## Prerrequisitos

- Cuenta AWS con permisos sobre EC2, SQS e IAM, región us-east-1.
- AWS CloudShell. Las credenciales salen de la sesión de la consola; no se usan access keys.
- Terraform >= 1.5 (probado con 1.9.8) y provider `hashicorp/aws ~> 5.0`.
- Una VPC existente con una subnet pública (ruta `0.0.0.0/0` hacia un Internet Gateway).

## Variables

| Variable | Obligatoria | Valor por defecto | Para qué |
|---|---|---|---|
| `vpc_name` | Sí | — | Tag Name de la VPC existente |
| `subnet_name` | Sí | — | Tag Name de la subnet pública |
| `aws_region` | No | us-east-1 | Región |
| `prefix` | No | cafeluna-tf | Prefijo de todo lo que crea el reto |
| `equipo` | No | 2 | Etiqueta Equipo |
| `instance_type` | No | t3.micro | Tipo de la EC2 |

## Uso

```bash
git clone https://github.com/Nicolaszj/Cloud-Computing-Equipo-2.git
cd Cloud-Computing-Equipo-2/terraform
cp terraform.tfvars.example terraform.tfvars   # poner vpc_name y subnet_name reales
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=reto.tfplan                # esperado: 6 to add, 0 to change, 0 to destroy
terraform apply reto.tfplan
```

## Validación funcional

Al arrancar, la EC2 envía a la cola el mensaje `pedido-prueba-terraform instance=<su instance-id>`. Esperar unos 2 minutos después del apply y leerlo:

```bash
terraform output -raw instance_id
aws sqs receive-message --queue-url "$(terraform output -raw queue_url)" --region us-east-1 --wait-time-seconds 10 --query 'Messages[].Body' --output text
```

La prueba pasa si el `instance=` del mensaje es igual al output `instance_id`. Eso demuestra EC2 → IAM Role → SQS sin SSH y sin credenciales.

## Cleanup

```bash
terraform state list     # solo recursos cafeluna-tf-* y data sources
terraform destroy        # esperado: 6 destroyed
aws ec2 describe-vpcs --filters Name=tag:Name,Values=cafeluna-vpc   # la VPC base sigue existiendo
```

## Registro de ejecución (2026-10-20)

| Gate | Resultado | Evidencia |
|---|---|---|
| terraform init | PASS | evidencias/E03-init.png |
| terraform validate | PASS | evidencias/E04-fmt-validate.png |
| terraform plan | PASS | evidencias/E05-plan.png |
| terraform apply | PASS | evidencias/E06-apply.png, evidencias/E07-iam-sg-ec2.png |
| functional check | PASS | evidencias/E08-functional-check.png |
| terraform destroy / cleanup | PASS | evidencias/E09-state-list.png, evidencias/E10-destroy.png, evidencias/E11-post-cleanup.png |

## Seguridad

- `.gitignore` excluye `.terraform/`, `*.tfstate*`, `*.tfplan` y `terraform.tfvars`.
- Ninguna credencial en el código ni en las variables.
- IAM: una acción (`sqs:SendMessage`) sobre un ARN (la cola del reto).
- EC2 sin key pair, sin puertos de entrada y con IMDSv2 obligatorio.
- El reto usa el prefijo `cafeluna-tf` y no toca la solución base del proyecto.

## Contribuciones

| Integrante | Rol | Contribución concreta |
|---|---|---|
| Nicolás Zapata Jurado | Security/CloudOps Engineer | Roles IAM con mínimo privilegio, grupos de seguridad, Secrets Manager, logs, panel y alarmas A1 a A3; reto Terraform   |
| Emily Cardona Castañeda | Arquitecta de soluciones | Diagrama de la arquitectura implementada, comparación con el Hito 2 y diseño del flujo de extremo a extremo simulado |
| Samuel Molina Echeverri | Cloud/IaC Engineer | Despliegue de VPC, ECS Fargate, ALB, RDS, SNS, SQS y worker; ejecución de las pruebas P1 a P9 |
| Alexander Vargas Atehortúa | FinOps y documentación | Estimación de costos, presupuesto y etiquetas, recomendaciones de optimización, instrucciones de operación y consolidación del documento |

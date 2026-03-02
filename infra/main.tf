# 1. DEFINIMOS EL PROVEEDOR (AWS)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. CONFIGURAMOS EL PROVEEDOR PARA QUE USE EL SIMULADOR
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # ⚠️ AQUÍ ESTÁ EL TRUCO: Redirigimos todo a LocalStack
  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    ec2      = "http://localhost:4566"
    iam      = "http://localhost:4566"
  }
}

# 3. RECURSO: Un Bucket S3 (Disco duro en la nube)
resource "aws_s3_bucket" "mi_bucket_terraform" {
  bucket = "cubo-creado-por-terraform"
}

# 4. RECURSO: Una Tabla de Base de Datos (DynamoDB)
resource "aws_dynamodb_table" "mi_tabla" {
  name           = "UsuariosVIP"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}
# ... (deja tu bucket y tu tabla como estaban arriba) ...

# 5. RECURSO: Un Servidor Virtual (EC2)
resource "aws_instance" "mi_servidor_web" {
  ami           = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"             

  vpc_security_group_ids = [aws_security_group.mi_firewall.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Actualizando sistema..."
              sudo apt-get update -y
              
              echo "Instalando Docker..."
              sudo apt-get install -y docker.io
              
              echo "Iniciando tu API en el puerto 80..."
              sudo docker run -d -p 80:8080 x3mzjd/backend-usuarios-go:v1.0.0
              EOF
  tags = {
     Name = "Servidor-App-Usuarios"
   }
 }
 # 6. RECURSO: El Portero (Security Group / Firewall)
resource "aws_security_group" "mi_firewall" {
  name        = "permitir_web_y_ssh"
  description = "Permite trafico HTTP y SSH"

  # Regla de ENTRADA: Puerto 80 (Web)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de ENTRADA: Puerto 22 (Terminal SSH)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Regla de SALIDA: Dejar que el servidor se conecte a internet (para descargar cosas)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

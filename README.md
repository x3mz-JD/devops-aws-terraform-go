# 🚀 Arquitectura Completa DevOps: Go + Docker + Terraform en AWS

Este proyecto es una demostración de una arquitectura de software moderna e inmutable.

## 🛠️ Tecnologías Utilizadas
* **Backend:** Go (Golang)
* **Contenedores:** Docker
* **Infraestructura como Código (IaC):** Terraform
* **Cloud:** AWS (Simulado con LocalStack)

## 🏗️ Cómo levantar este proyecto
1. Levantar el simulador: `docker compose up -d`
2. Entrar en la carpeta infra: `cd infra`
3. Desplegar la nube: `terraform init && terraform apply --auto-approve`

Al finalizar, Terraform te devolverá la IP pública donde está corriendo la API.

output "ip_publica_servidor" {
  description = "La IP publica para entrar a mi API"
  value       = aws_instance.mi_servidor_web.public_ip
}

output "id_del_servidor" {
  description = "El identificador interno en AWS"
  value       = aws_instance.mi_servidor_web.id
}

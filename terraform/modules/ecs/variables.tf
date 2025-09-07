# Variables generales
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev, prod, etc.)"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

# Variables de red
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Lista de CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidad"
  type        = list(string)
}

# Variables de ECS
variable "task_cpu" {
  description = "CPU units para la task definition"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memoria en MB para la task definition"
  type        = number
  default     = 512
}

variable "service_desired_count" {
  description = "Número deseado de instancias del servicio"
  type        = number
  default     = 1
}

# Variables de ECR
variable "ecr_repository_url" {
  description = "URL del repositorio ECR"
  type        = string
}

provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source = "./modules/ecr"

  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
}

module "ecs" {
  source = "./modules/ecs"

  project_name      = var.project_name
  environment       = var.environment
  aws_region       = var.aws_region
  ecr_repository_url = module.ecr.repository_url
  
  # Configuración de red
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_cidr          = "10.0.0.0/16"
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # Configuración de ECS
  task_cpu             = 256
  task_memory          = 512
  service_desired_count = 1
}

# Variables globales
variable "aws_region" {
  description = "AWS region donde se crearán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "spacex-app"
}

# Outputs
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "vpc_id" {
  value = module.ecs.vpc_id
}

output "public_subnet_ids" {
  value = module.ecs.public_subnet_ids
}

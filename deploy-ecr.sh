#!/bin/bash

# Cargar variables de entorno
source .env

# Iniciar sesión en ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Crear repositorios ECR si no existen
aws ecr create-repository --repository-name spacex-frontend --region ${AWS_REGION} || true
aws ecr create-repository --repository-name spacex-backend --region ${AWS_REGION} || true

# Construir imágenes
docker-compose build

# Etiquetar y subir imágenes
docker-compose push

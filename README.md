# SpaceX Web Fullstack

Repositorio principal para el despliegue completo de la aplicación web SpaceX. Contiene la infraestructura como código (Terraform), configuración de Docker, pipelines de CI/CD y orquestación de todos los componentes del sistema.

## Descripción

Este proyecto integra todos los componentes de la aplicación SpaceX en un sistema completo:

- **Backend API** (FastAPI) como submódulo
- **Frontend Web** (Vue.js) como submódulo  
- **Infraestructura AWS** (ECS Fargate, ECR, ALB)
- **Pipelines CI/CD** (GitHub Actions)
- **Containerización** (Docker & Docker Compose)

## Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │  Load Balancer  │    │    Backend      │
│   (Vue.js)      │◄──►│     (ALB)       │◄──►│   (FastAPI)     │
│   Puerto 80     │    │                 │    │   Puerto 8000   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ECS Fargate   │    │   Amazon ECR    │    │   DynamoDB      │
│   Container     │    │  Image Registry │    │  spacex_launches│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Tecnologías

- **Infraestructura**: Terraform, AWS (ECS, ECR, ALB, VPC)
- **Containerización**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Networking**: VPC, Subnets, Security Groups
- **Monitoring**: CloudWatch, Health Checks

## Estructura del Proyecto

```
spacex_web_fullstack/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # Pipeline principal
├── backend/                    # Submódulo backend
├── frontend/                   # Submódulo frontend  
├── terraform/                  # Infraestructura como código
│   ├── main.tf                 # Configuración principal
│   └── modules/
│       ├── ecr/                # Módulo ECR
│       └── ecs/                # Módulo ECS
├── .env                        # Variables de entorno
├── .env-example                # Ejemplo de configuración
├── .gitmodules                 # Configuración submódulos
├── docker-compose.yml          # Orquestación local
├── Dockerfile                  # Imagen integrada
├── nginx.conf                  # Configuración web server
├── deploy-ecr.sh              # Script despliegue ECR
├── push-to-ecr.sh             # Script push imágenes
├── start.sh                   # Script inicio aplicación
└── trust-policy.json          # Políticas IAM
```

## Requisitos Previos

- AWS CLI configurado
- Docker y Docker Compose
- Terraform >= 1.0
- Git con soporte para submódulos
- Credenciales AWS con permisos para ECS, ECR, VPC

## Instalación

### 1. Clonar con submódulos

```bash
git clone --recurse-submodules https://github.com/mariaabonilla11/spacex_web_fullstack.git
cd spacex_web_fullstack
```

### 2. Configurar variables de entorno

```bash
cp .env-example .env
# Editar .env con tus credenciales AWS
```

### 3. Configurar credenciales AWS

```bash
aws configure
```

## Desarrollo Local

### Docker Compose

```bash
# Construir imágenes
docker-compose build

# Levantar aplicación completa
docker-compose up

# Detener servicios
docker-compose down
```

### Servicios individuales

#### Backend solamente
```bash
cd backend
docker build -t spacex-backend .
docker run -d -p 8000:8000 --name spacex-backend spacex-backend
```

#### Frontend solamente
```bash
cd frontend
docker build -t spacex-frontend .
docker run -d -p 80:80 --name spacex-frontend spacex-frontend
```

## Despliegue en AWS

### 1. Crear infraestructura

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Esto crea:
- Repositorio ECR para imágenes Docker
- VPC con subnets públicas
- ECS Cluster con Fargate
- Application Load Balancer
- Security Groups y reglas de red

### 2. Construir y subir imagen

```bash
# Opción 1: Script automatizado
./push-to-ecr.sh

# Opción 2: Comandos manuales
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build --platform linux/amd64 -t spacex-app .
docker tag spacex-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/spacex-app:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/spacex-app:latest
```

### 3. Verificar despliegue

```bash
# Verificar servicios ECS
aws ecs describe-services --cluster spacex-cluster --services spacex-service

# Obtener URL del Load Balancer
aws elbv2 describe-load-balancers --names spacex-app-alb
```

## URLs de Acceso

- **Aplicación Web**: http://spacex-app-alb-1144963660.us-east-1.elb.amazonaws.com/
- **API Docs**: http://spacex-app-alb-1144963660.us-east-1.elb.amazonaws.com/api/v1/docs

## CI/CD Pipeline

### GitHub Actions

El pipeline se ejecuta automáticamente en push a `main` o manualmente:

1. **Test**: Ejecuta pruebas del backend
2. **Build**: Construye imagen Docker multi-arquitectura
3. **Deploy**: 
   - Sube imagen a ECR
   - Actualiza servicio ECS
   - Espera estabilización
   - Notifica resultado

### Configurar Secrets

En GitHub, agregar en Settings > Secrets:

```
AWS_ACCESS_KEY_ID=<tu_access_key>
AWS_SECRET_ACCESS_KEY=<tu_secret_key>
PERSONAL_ACCESS_TOKEN=<github_token>
```

### Trigger desde otros repos

Los repositorios backend y frontend pueden disparar este pipeline:

```yaml
- name: Trigger main deployment
  uses: peter-evans/repository-dispatch@v2
  with:
    token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
    repository: mariaabonilla11/spacex_web_fullstack
    event-type: deploy-trigger
```

## Configuración de Red

### Load Balancer Rules

- **Puerto 80**: Punto de entrada público
- **Ruta /api/\***: Redirige al backend (puerto 8000)
- **Resto de rutas**: Redirige al frontend (puerto 80)

### Security Groups

- **ALB Security Group**: Permite HTTP (80) desde internet
- **ECS Security Group**: Permite 80 y 8000 desde ALB
- **VPC Endpoints**: Acceso privado a ECR y S3

## Scripts Útiles

### deploy-ecr.sh
Script completo para despliegue que incluye:
- Autenticación ECR
- Build de imagen
- Tag y push
- Actualización de servicio ECS

### start.sh
Script de inicio de la aplicación que:
- Inicia Nginx
- Sirve frontend en puerto 80
- Proxy al backend en puerto 8000

## Testing

### Pruebas del backend
```bash
docker exec spacex-backend pytest app/tests/test_basic_endpoints.py -v -s
```

### Health Checks
```bash
# Backend health
curl http://localhost:8000/health

# Frontend
curl http://localhost:80

# En producción
curl http://spacex-app-alb-1144963660.us-east-1.elb.amazonaws.com/health
```

## Troubleshooting

### Problemas comunes

#### Servicios ECS no arrancan
```bash
# Verificar logs
aws logs tail /ecs/spacex-app --follow

# Verificar definición de tarea
aws ecs describe-task-definition --task-definition spacex-app
```

#### Error de autenticación ECR
```bash
# Re-autenticar
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

#### Load Balancer no responde
```bash
# Verificar health checks
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Submódulos

### Actualizar submódulos

```bash
# Actualizar a última versión
git submodule update --remote

# Confirmar cambios
git add backend frontend
git commit -m "Update submodules"
```

### Enlaces a repositorios

- **Backend**: https://github.com/mariaabonilla11/spacex_web_backend
- **Frontend**: https://github.com/mariaabonilla11/spacexweb_frontend
- **Lambda**: https://github.com/mariaabonilla11/spacex_fullstack

## Contribución

1. Fork el proyecto
2. Crear branch para feature
3. Hacer cambios en submódulos si es necesario
4. Actualizar configuración de infraestructura
5. Probar localmente con Docker Compose
6. Abrir Pull Request


## Autor

**Maria del Pilar Bonilla**
- GitHub: [@mariaabonilla11](https://github.com/mariaabonilla11)

# syntax=docker/dockerfile:1

# Etapa de construcción del frontend
FROM --platform=$BUILDPLATFORM node:16-alpine as frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Etapa de construcción del backend
FROM --platform=$BUILDPLATFORM python:3.11-slim as backend-builder
WORKDIR /app/backend
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ .

# Etapa final
FROM --platform=$TARGETPLATFORM python:3.11-slim
WORKDIR /app

# Instalar Nginx y dependencias necesarias
RUN apt-get update && \
    apt-get install -y nginx curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/nginx/html && \
    chown -R www-data:www-data /usr/share/nginx/html && \
    rm /etc/nginx/sites-enabled/default

# Copiar y instalar requirements.txt del backend
COPY backend/requirements.txt /app/backend/
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# Copiar el frontend construido y establecer permisos
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html/
RUN chown -R www-data:www-data /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Copiar el backend
COPY --from=backend-builder /app/backend /app/backend

# Configurar Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80 8000
CMD ["/start.sh"]

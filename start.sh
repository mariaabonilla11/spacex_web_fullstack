#!/bin/sh

# Asegurarse de que el directorio existe y tiene los permisos correctos
mkdir -p /usr/share/nginx/html
chown -R www-data:www-data /usr/share/nginx/html

# Verificar que los archivos estén presentes
echo "Contenido del directorio /usr/share/nginx/html:"
ls -la /usr/share/nginx/html

# Verificar la configuración de nginx
nginx -t

# Iniciar el backend en segundo plano
cd /app/backend && uvicorn main:app --host 0.0.0.0 --port 8000 &

# Esperar un momento para que el backend inicie
sleep 5

# Iniciar Nginx en primer plano
nginx -g 'daemon off;'

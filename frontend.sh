#!/bin/bash
# frontend.sh: Instala dependencias e inicializa el servicio frontend (Vue.js).

# Verificar instalación de Node.js
if ! command -v node &>/dev/null; then
    echo "Node.js no está instalado. Instalando Node.js..."
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
fi

# Ir al directorio del frontend
cd "$(dirname "$0")/frontend" || { echo "Directorio frontend no encontrado"; exit 1; }

# Instalar dependencias de npm si no existen
if [ ! -d "node_modules" ]; then
    echo "Instalando dependencias de npm..."
    npm install
fi

# Variables de entorno
export NODE_ENV=${NODE_ENV:-development}
export FRONTEND_PORT=${FRONTEND_PORT:-3000}
export API_URL=${API_URL:-http://localhost:5000}

echo "Iniciando el frontend en el puerto ${FRONTEND_PORT}..."
exec npm run serve -- --port "${FRONTEND_PORT}"

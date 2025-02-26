#!/bin/bash
# frontend.sh: Instala dependencias e inicializa el servicio frontend (Vue.js).
# Ubicación: raíz del proyecto. La carpeta 'frontend' se encuentra en la raíz.
# Repositorio: https://github.com/JuanMi-CG/Flask_Node_MySQL_Jupyter

# Verificar si Node.js está instalado
if ! command -v node &>/dev/null; then
    echo "Node.js no está instalado. Instalando Node.js..."
    curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo yum install -y nodejs
fi

# Cambiar al directorio 'frontend'
cd "$(dirname "$0")/frontend" || { echo "Directorio 'frontend' no encontrado"; exit 1; }

# Instalar dependencias de npm si no existen
if [ ! -d "node_modules" ]; then
    echo "Instalando dependencias de npm..."
    npm install
fi

# Agregar node_modules/.bin al PATH para encontrar vue-cli-service
export PATH="$(pwd)/node_modules/.bin:$PATH"

# Variables de entorno (pueden ser sobreescritas externamente)
export NODE_ENV=${NODE_ENV:-development}
export FRONTEND_PORT=${FRONTEND_PORT:-3000}
export API_URL=${API_URL:-http://localhost:5000}

# Si hay algún proceso ejecutándose en el puerto, se reinicia (se finaliza dicho proceso)
PID=$(lsof -ti tcp:"${FRONTEND_PORT}")
if [ -n "$PID" ]; then
    echo "El frontend ya se está ejecutando en el puerto ${FRONTEND_PORT}. Reiniciando..."
    kill -9 $PID
    sleep 2
fi

# Iniciar el servicio frontend
echo "Iniciando el frontend en el puerto ${FRONTEND_PORT}..."
npm run serve -- --port "${FRONTEND_PORT}"
EXIT_CODE=$?

# Si ocurre un error al iniciar, y en particular no se encuentra vue-cli-service, borrar node_modules y reinstalar
if [ $EXIT_CODE -ne 0 ]; then
    if [ ! -x "$(pwd)/node_modules/.bin/vue-cli-service" ]; then
         echo "Error: vue-cli-service no encontrado. Borrando node_modules..."
         rm -rf node_modules
         echo "Reinstalando dependencias de npm..."
         npm install
         # Reconfigurar PATH con los nuevos binarios
         export PATH="$(pwd)/node_modules/.bin:$PATH"
         echo "Reiniciando el frontend en el puerto ${FRONTEND_PORT}..."
         npm run serve -- --port "${FRONTEND_PORT}"
    else
         echo "Ocurrió un error al iniciar el frontend. Código de salida: $EXIT_CODE"
    fi
fi


# #!/bin/bash
# # frontend.sh: Instala dependencias e inicializa el servicio frontend (Vue.js).

# # Verificar instalación de Node.js
# if ! command -v node &>/dev/null; then
#     echo "Node.js no está instalado. Instalando Node.js..."
#     curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
#     sudo yum install -y nodejs
# fi

# # Ir al directorio del frontend
# cd "$(dirname "$0")/frontend" || { echo "Directorio frontend no encontrado"; exit 1; }

# # Instalar dependencias de npm si no existen
# if [ ! -d "node_modules" ]; then
#     echo "Instalando dependencias de npm..."
#     npm install
# fi

# # Variables de entorno
# export NODE_ENV=${NODE_ENV:-development}
# export FRONTEND_PORT=${FRONTEND_PORT:-3000}
# export API_URL=${API_URL:-http://localhost:5000}

# echo "Iniciando el frontend en el puerto ${FRONTEND_PORT}..."
# exec npm run serve -- --port "${FRONTEND_PORT}"

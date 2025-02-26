#!/bin/bash
# backend.sh: Instala dependencias e inicializa el servicio backend (Flask).

# Verificar que Python3 esté instalado
if ! command -v python3 &>/dev/null; then
    echo "Python3 no está instalado. Instalando..."
    sudo yum install -y python3
fi

# Verificar que pip3 esté instalado
if ! command -v pip3 &>/dev/null; then
    echo "pip3 no está instalado. Instalando..."
    sudo yum install -y python3-pip
fi

# Ir al directorio del backend
cd "$(dirname "$0")/backend" || { echo "Directorio backend no encontrado"; exit 1; }

# Verificar si el entorno virtual existe
if [ -d "venv" ]; then
    echo "Activando entorno virtual..."
    source venv/bin/activate
    
    # Verificar si Flask está instalado, si no, eliminar y recrear venv
    if ! python3 -c "import flask" &>/dev/null; then
        echo "Error: No se encontró Flask en el entorno virtual. Eliminando y recreando venv..."
        deactivate 2>/dev/null
        rm -rf venv
    fi
fi

# Crear y activar entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "Creando entorno virtual e instalando dependencias..."
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
fi

# Variables de entorno (se pueden sobrescribir externamente)
export FLASK_ENV=${FLASK_ENV:-development}
export FLASK_APP=${FLASK_APP:-run.py}
export FLASK_DEBUG=${FLASK_DEBUG:-1}
export BACKEND_PORT=${BACKEND_PORT:-5000}
export MYSQL_USER=${MYSQL_USER:-remoto}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-Remoto123!}
export MYSQL_DATABASE=${MYSQL_DATABASE:-ERP}
export DATABASE_URI=${DATABASE_URI:-"mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@localhost:3306/${MYSQL_DATABASE}"}

echo "Iniciando el backend en el puerto ${BACKEND_PORT}..."
exec venv/bin/python3 -m flask run --host=0.0.0.0 --port "${BACKEND_PORT}"

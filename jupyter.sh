#!/bin/bash
# jupyter.sh: Instala Jupyter Notebook (si no está instalado) e inicializa el servicio.

# Verificar si jupyter-notebook está instalado
if ! command -v jupyter-notebook &>/dev/null; then
    echo "Jupyter Notebook no encontrado. Instalando..."
    sudo pip3 install --ignore-installed jupyter
fi

# Verificar nuevamente la instalación
if ! command -v jupyter-notebook &>/dev/null; then
    echo "La instalación de Jupyter Notebook falló o no se encuentra en el PATH."
    exit 1
fi

# Cambiar al directorio de notebooks
cd "$(dirname "$0")/notebooks" || { echo "Directorio notebooks no encontrado"; exit 1; }

# Variables de entorno
export JUPYTER_PORT=${JUPYTER_PORT:-8888}
export JUPYTER_TOKEN=${JUPYTER_TOKEN:-miclave}

echo "Iniciando Jupyter Notebook en el puerto ${JUPYTER_PORT}..."
exec jupyter-notebook --ip=0.0.0.0 --port "${JUPYTER_PORT}" --NotebookApp.token="${JUPYTER_TOKEN}" --no-browser

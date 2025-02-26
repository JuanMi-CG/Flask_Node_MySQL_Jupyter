#!/bin/bash
# init.sh: Inicializa (o reinicia) todos los servicios.

# Ubicación del directorio actual (se asume que es la raíz del repositorio)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Iniciando servicio de base de datos..."
sudo "$BASE_DIR/db.sh" > db.log 2>&1 
# Esperar a que la base de datos esté lista (ajustar el tiempo si es necesario)
sleep 15

echo "Iniciando backend (Flask)..."
sudo "$BASE_DIR/backend.sh" > backend.log 2>&1 &

echo "Iniciando frontend (Vue.js)..."
sudo "$BASE_DIR/frontend.sh" > frontend.log 2>&1 &

echo "Iniciando Jupyter Notebook..."
sudo "$BASE_DIR/jupyter.sh" > jupyter.log 2>&1 &

echo "Todos los servicios han sido iniciados."

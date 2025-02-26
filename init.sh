#!/bin/bash
# init.sh: Inicializa (o reinicia) todos los servicios.

# Ubicación del directorio actual (se asume que es la raíz del repositorio)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Iniciando servicio de base de datos..."
sudo "$BASE_DIR/db.sh" &
# Esperar a que la base de datos esté lista (ajustar el tiempo si es necesario)
sleep 15

echo "Iniciando backend (Flask)..."
sudo "$BASE_DIR/backend.sh" &

echo "Iniciando frontend (Vue.js)..."
sudo "$BASE_DIR/frontend.sh" &

echo "Iniciando Jupyter Notebook..."
sudo "$BASE_DIR/jupyter.sh" &

echo "Todos los servicios han sido iniciados."

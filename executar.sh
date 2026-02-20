#!/bin/bash
# Script para Linux/Mac

echo "========================================"
echo "Sticky Notes App"
echo "========================================"
echo ""

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "ERRO: Flutter não encontrado!"
    echo "Por favor instale o Flutter em:"
    echo "https://docs.flutter.dev/get-started/install"
    exit 1
fi

cd "$(dirname "$0")"

# Detectar sistema operativo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "A executar no Linux..."
    flutter run -d linux --hot
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "A executar no macOS..."
    flutter run -d macos --hot
else
    echo "Sistema operativo não suportado"
    exit 1
fi
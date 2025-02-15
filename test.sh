#!/usr/bin/env bash

if [ ! -f bin/parser ]; then
    echo "Compilando o tradutor..."
    ./compile.sh
fi

echo "Programas disponíveis:"
ls -1 programs/*.esp | nl

echo -n "Selecione o número do programa para testar (ou 'all' para testar todos): "
read choice

if [ "$choice" = "all" ]; then
    for esp in programs/*.esp; do
        echo "Testando $esp..."
        bin/parser "$esp"
    done
else
    file=$(ls programs/*.esp | sed -n "${choice}p")
    if [ -n "$file" ]; then
        echo "Testando $file..."
        bin/parser "$file"
    else
        echo "Seleção inválida"
    fi
fi
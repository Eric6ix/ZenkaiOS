#!/bin/bash

echo "== Limpando cache do pacman =="
sudo pacman -Sc

echo "== Removendo órfãos =="
orphans=$(pacman -Qtdq)

if [ -n "$orphans" ]; then
  sudo pacman -Rns $orphans
else
  echo "Nenhum pacote órfão encontrado"
fi

echo "== Limpando logs antigos =="
sudo journalctl --vacuum-time=7d

echo "== Finalizado =="

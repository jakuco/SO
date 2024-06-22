#!/bin/bash
#set -x

nombre_grupo="$2"
usuario="$3"
#path_grupos="/etc/group"
path_grupos="./copia_group"
if [[ "$1" == "-a" ]]; then
 #echo "+Añadir grupo"
 if ! grep -q "$nombre_grupo" "$path_grupos"; then
  #echo "No se encuentra el grupo $nombre_grupo"
  # obtiene el valor de GID mas grande
  gid_max=$(sudo cut -d: -f3 "$path_grupos" | sort -n | tail -n1)
  gid_nuevo_grupo=$((1 + gid_max))
  linea_group="$nombre_grupo:x:$gid_nuevo_grupo:$usuario"
  sudo echo "$linea_group" >> "$path_grupos"
  #echo "El GID maximo es: $gid_nuevo_grupo"
  #echo "La linea es: $linea_group"
 else
  #echo "Existe el grupo $nombre_grupo"
  linea_group=$(sudo grep "$nombre_grupo" "$path_grupos")
  linea_group="$linea_group,$usuario"
  # reemplaza la linea de group por una nueva
  numero_linea=$(sudo grep -n "$nombre_grupo" "$path_grupos" | cut -d: -f1)
  #echo "La linea es: $linea_group, y su posicion es $numero_linea"
  # modifica la línea previamente guardada
  sudo sed -i "${numero_linea}c $linea_group" "$path_grupos"
  #echo "$gid_nuevo_grupo"
 fi
fi

if [[ "$1" == "-e" ]]; then
 echo "Eliminar grupo" 
fi



#!/bin/bash
# crear_usuarios "nombre del archivo"

path_us="./copia_passwd"
path_gp="./copia_group"
path_sh="./copia_shadow"
path_gsh="./copia_gshadow"

obt_num_usuario(){
 usuario="$1"
 if grep -q "$usuario" "$path_us"; then
  numero_linea=$(sudo cut -d: -f1 "$path_us" | grep "$usuario" | wc -l)
  echo "Numero linea usuario $numero_linea"
  usuario="$usuario$numero_linea"
  echo "El usuario nuevo sería $usuario"
 fi
}

obtener_usuario(){
 nombre=$(echo "$1" | cut -d" " -f1)
 apellido1=$(echo "$1" | cut -d" " -f2)
 apellido2=$(echo "$1" | cut -d" " -f3)
 departamento=$(echo "$1" | cut -d" " -f4)

 usuario="${nombre:0:1}.${apellido1}.${apellido2:0:1}"
 if grep -q "$usuario" "$path_us"; then
  numero_linea=$(sudo cut -d: -f1 "$path_us" | grep "$usuario" | wc -l)
  usuario="$usuario$numero_linea"
 fi
 . ./gestionar_grupos.sh "-a" "$departamento" "$usuario"
 GID=$(sudo grep "$departamento" "$path_gp" | cut -d: -f3)
 uid_max=$(sudo cut -d: -f3 "$path_us" | sort -n | tail -n1)
 uid=$((1 + uid_max))
 linea_usuario="$usuario:x:$uid:$GID:$nombre $apellido1 $apellido2:/home/$usuario:/bin/bash"
 sudo echo "$linea_usuario" >> "$path_us"

 # Ingresa información el documento shadow
 contrasegna=$(sudo openssl passwd -6 "$usuario")
 echo "La contraseña es $contrasegna"
 fecha_actual=$(($(date +%s) / 86400))
 linea_shadow="$usuario:$contrasegna:$fecha_actual:0:99999:7:::"
 sudo echo "$linea_shadow" >> "$path_sh"

 # crea el fichero y da permisos al nuevo usuario
 sudo mkdir "/home/$usuario"
 sudo chown "$usuario:$usuario" "/home/$usuario"
 sudo chmod 755 "/home/$usuario"
 #echo "$usuario"
}



#echo "Ingrese el nombre del usuario"
#read nombre
#echo "Ingrese el primer apellido"
#read primer_apellido
#echo "Ingrese el segundo apellido"
#read segundo_apellido



#direccion=$(dirname "$0")
direccion=$(realpath  "$1")

#more "$direccion"
mapfile -t datos < "$direccion"

for linea in "${datos[@]}";
do
 obtener_usuario "$linea"
done

#!/bin/bash

PORT=60100
SERVER_IP=$1

echo "BUSCANDO SERVIDOR"
# 1 ENVIA HELLO AL SERVER
echo "HELLO" | nc -q 0 $SERVER_IP $PORT

# 2 ESCUCHA DEL SERVER
msg=$(nc -l -p $PORT)

salto=$(echo "$msg" | cut -d ":" -f 2)
echo "$salto"

OK_L=$(echo "$msg" | cut -d ":" -f 1)

# 2.2 SI ES DIFERENTE DE HELLO; CIERRA
echo "SERVER ESCUCHADO"
if [[ "$OK_L" != "OK_HEADER" ]]; then
  echo "KO" | nc -q 0 $SERVER_IP $PORT
  echo "Connexió rebutjada"
  exit 1
fi

echo "SERVER ENCONTRADO"

# 3 PREGUNTAR USUARIO Y CLAVE
read -p "USERNAME:  " user

read -p "PASSWORD:  " CLIENT_PASSWORD

# 4 ENCRIPTA LA CLAVE
hash_contrasenya=$(printf "%s" "$CLIENT_PASSWORD" | sha256sum | cut -d' ' -f1)

hash_salt=$(printf "%s%s" "$hash_contrasenya" "$salto" | sha256sum | cut -d' ' -f1)

# 5 ENVIA EL MENSAJE ENTERO
echo "AUTH:$user:$hash_salt" | nc -q 0 $SERVER_IP $PORT


APROV=$(nc -l -p $PORT)

echo "$APROV"


exit 0

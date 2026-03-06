#!/bin/bash

PORT=60100
CLIENT_IP=$1
RANDOM=54321
PASSWORD=$"abcd1234"
USER_REG=$"ABCD"


echo "BUSCANDO CLIENTE"
# 1 SERVER ESCUCHA
msg=$(nc -l -p $PORT)

# 1.1 SI MENSAJE ESCUCHADO ES DIFERENTE DE HELLO, REGRESA KO
if [[ "$msg" != "HELLO" ]]; then
  echo "KO" | nc -q 0 $CLIENT_IP $PORT
  echo "Connexió rebutjada" |
  exit 1
fi
echo "CLIENTE ENCONTRADO"

# 2 REGRESA OK AL CLIENTE Y LA VARIABLE RANDOM
salto=$RANDOM
echo "OK_HEADER:$salto" | nc -q 0 $CLIENT_IP $PORT
echo "OK ENVAIDO"

# 3 ESCUCHA MENSAJE  DE CLIENTE
AUTH=$(nc -l -p $PORT)

# 3.1 CORTA MENSAJE DE CLIENTE
HEADER=$(echo $AUTH | cut -d ":" -f 1)
USER=$(echo $AUTH | cut -d ":" -f 2)
CLIENT_PASSWORD=$(echo $AUTH | cut -d ":" -f 3)

# 4 DESENCRIPTA
hash_contrasenya=$(printf "%s" "$PASSWORD" | sha256sum | cut -d' ' -f1)

hash_salt=$(printf "%s%s" "$hash_contrasenya" "$salto" | sha256sum | cut -d' ' -f1)


# 5 FILTRA LA CONTRASEÑA
if [[ "$HEADER" != "AUTH" ]]; then
  echo "KO_AUTH" | nc -q 0 $CLIENT_IP $PORT
  echo "Connexió rebutjada"
  exit 1

elif [[ "$USER" != "$USER_REG" ]]; then
  echo "KO_USER" | nc -q 0 $CLIENT_IP $PORT
  echo "Connexió rebutjada"
  exit 2

elif [[ "$CLIENT_PASSWORD" != "$hash_salt" ]]; then
  echo "KO_PASSWORD" | nc -q 0 $CLIENT_IP $PORT
  echo "Connexió rebutjada"
  exit 3
fi


echo "USER CONNECTED"

echo "APROVED" | nc -q 0 $CLIENT_IP $PORT

exit 0

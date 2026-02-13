#!/bin/bash

SERVER_IP="10.65.0.41"
PORT=60000

echo "Conectant..."

echo "HELLO" | nc -q 3 $SERVER_IP $PORT

# Era que no habia tiempo para recibir un mensaje
response=$(nc -l -p $PORT)

echo "DEBUG"

if [[ "$response" != "OK" ]]; then
  echo "Conexio Rebutjada"
  exit 1
fi

while true; do
  echo "Esperand Torn ..."

  # Sacaba el temps despera quan el servidor acaba el torn
  response=$(nc -l -p $PORT)

  # TODO: Gestió de missatges rebuts
  # SERVER_WIN
  # CLIENT_WIN
  # MOVE_CLIENT
  # ...

  # == TORN CLIENT ==
  # TODO: pregunta posició i s'envia al servidor
  echo "MOVE $pos" | nc -q 0 $SERVER_IP $PORT

done

exit 0

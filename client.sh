#!/bin/bash

SERVER_IP="192.168.1.57"
PORT=60000

echo "HELLO" | nc -q 0 $SERVER_IP $PORT
response=$(nc -l -p $PORT)

if [[ "$response" != "OK" ]]; then
  exit 1
fi

while true; do

  echo "Esperant el torn ..."

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

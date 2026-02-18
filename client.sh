#!/bin/bash

SERVER_IP="10.65.0.44"
PORT=50000
BOARD=(1 2 3 4 5 6 7 8 9)


echo "Trobant Conexio"

echo "HELLO" | nc "10.65.0.44" "50000"

echo "HELLO enviat"

#echo "HELLO" | nc $SERVER_IP $PORT

response=$(nc -l -p $PORT)

if [[ "$response" != "OK" ]]; then
  echo "Conexio Rebutjada"
  exit 1
fi


if[[ "$response" == "OK" ]]; then

echo "Conectat"
fi

while true; do
  echo "Esperand Torn ..."

  # Sacaba el temps despera quan el servidor acaba el torn
  response=$(nc -l -p $PORT)

  # TODO: Gestió de missatges rebuts
  

  ## BOARD
  #print_board()

  # SERVER_WIN
  # CLIENT_WIN
  # MOVE_CLIENT
  # ...

  # == TORN CLIENT ==
  # TODO: pregunta posició i s'envia al servidor
  #echo "MOVE $pos" | nc -q 0 $SERVER_IP $PORT

done

exit 0

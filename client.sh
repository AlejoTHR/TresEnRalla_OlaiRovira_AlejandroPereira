#!/bin/bash

SERVER_IP=$1
PORT=50000
BOARD=(1 2 3 4 5 6 7 8 9)

# FUNCION BOARD DE PLAYER
print_board() {
  echo " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
  echo "---+---+---"
  echo " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
  echo "---+---+---"
  echo " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} "
}

echo "Trobant Conexio"

# ENVIA MENSAJE A SERVER PARA CONFIRMA CONECCION
echo "HELLO" | nc -q 0 $SERVER_IP $PORT

echo "HELLO enviat. Esperant resposta..."

# ESCUCHA MENSAJE DE REGRESO DEL SERVER
response=$(nc -l -p $PORT)

# SI RESPUESTA ES OK CONECTA SI NO DA ERROR
if [ "$response" != "OK" ]; then
  echo "Conexio Rebutjada"
  exit 1
fi

if [ "$response" = "OK" ]; then
echo "Conectat"
fi


# DURANTE EL BUCLEDEL JUEGO

	while true; do
# MUESTRA EL BOARD
  print_board

# ESPERA EL TURNO
  echo "Esperant Torn ..."

# RECIBE CASILLA YA ESCOGIDA POR EL SERVSER
  ServerMsg=$(nc -l -p $PORT)

# FILTRA EL MENSAJE

  MessageHeader=$(echo "$ServerMsg" | cut -d ":" -f 1)

  Board_IndexS=$(echo "$ServerMsg" | cut -d ":" -f 2)

  echo $MessageHeader
  echo $Board_IndexS

  if [ $MessageHeader = "SERVER_MOVEMENT" ]; then
	echo "L'Oponent ha mogut una peça"

  elif [ $MessageHeader  = "CLIENT_WIN" ]; then
	echo "Has Guanyat"
	break

  elif [ $MessageHeader = "SERVER_WIN" ]; then
	echo "Has Perdut"
	BOARD[Board_IndexS]="O"
	break

  elif [ $MessageHeader = "BYE" ]; then
	echo "L'Oponent s'ha desconectat"

  else
	echo "[ERROR] El Server ha enviat un missatge incorrecte"
	exit 1
  fi



#CAMBIA CASILLA ESCOGIDA POR EL SERVER
  BOARD[Board_IndexS]="O"
  print_board

#TURNO DEL PLAYER ENVIADO AL SERVIDOR
  read -p "Posició del Jugador(1-9): " pos

# TRANSFORMA A INDICE Y LO MARCA EN EL BOARD
  Board_IndexP=$((pos - 1))
  BOARD[Board_IndexP]="X"

# ENVIA MOVIMIENTO AL SERVER
  echo "CLIENT_MOVEMENT:$Board_IndexP" | nc -q 0 $SERVER_IP $PORT

done

print_board

exit 0

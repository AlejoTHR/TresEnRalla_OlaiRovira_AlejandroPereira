#!/bin/bash

SERVER_IP=$1
PORT=50000
BOARD=(1 2 3 4 5 6 7 8 9)

RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'


LOG_FILE=$2

EXIT_OP="/q"


# CONDICIPN ED VICTORIA Y DERROTA LA MANEJA EL server.sh
# FUNCION BOARD DE PLAYER
print_board() {
  echo -e " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} \n"
}


#0.1 MISSATGE DE PRESENTACIÓ
echo -e "\n\t\t--||:: BENVINGUT A TRES EN RATLLA UBU ::||--\n\n"

while (true); do


echo "Trobant Conexio"

# ENVIA MENSAJE A SERVER PARA CONFIRMA CONECCION
echo "HELLO" | nc -q 0 $SERVER_IP $PORT

echo "HELLO enviat. Esperant resposta..." | tee -a $LOG_FILE

# ESCUCHA MENSAJE DE REGRESO DEL SERVER
response=$(nc -l -p $PORT)

# SI RESPUESTA ES OK CONECTA SI NO DA ERROR
if [ "$response" != "OK" ]; then
  echo "Conexio Rebutjada" | tee -a $LOG_FILE
  break
fi

if [ "$response" = "OK" ]; then
echo "Conectat" | tee -a $LOG_FILE
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
	#CABECERA DEL MENSAJE
  MessageHeader=$(echo "$ServerMsg" | cut -d ":" -f 1)
	#NUMERO DE CASILLA
  Board_IndexS=$(echo "$ServerMsg" | cut -d ":" -f 2)

	# FILTRO DE CABECERA DE MENSAJE
  if [ $MessageHeader = "SERVER_MOVEMENT" ]; then
	echo "L'Oponent ha mogut una peça"

  elif [ $MessageHeader  = "CLIENT_WIN" ]; then
	echo "Has Guanyat"
	echo "CLIENT_WON" >> $LOG_FILE
	break

  elif [ $MessageHeader = "SERVER_WIN" ]; then
	echo "Has Perdut"
	BOARD[Board_IndexS]="${BLUE}O${WHITE}"
	break

  elif [ $MessageHeader = "BYE" ]; then
	echo "L'Oponent s'ha desconectat" | tee -a $LOG_FILE

  else
	echo "[ERROR] El Server ha enviat un missatge incorrecte" | tee -a $LOG_FILE
	exit 1
  fi



#CAMBIA CASILLA ESCOGIDA POR EL SERVER
  BOARD[Board_IndexS]="${BLUE}O${WHITE}"
  print_board

#TURNO DEL PLAYER ENVIADO AL SERVIDOR


  read -p "Posició del Jugador(1-9): " pos
  Board_IndexP=$((pos - 1))

  while [[ "${BOARD[${board_index}]}" == "X" || "${BOARD[${board_index}]}" == "O" ]]; do
  read -p "Posició incorrecta, torna a provar-ho (1-9): " pos
  Board_IndexP=$((pos - 1))

  done

  BOARD[$Board_IndexP]="${RED}X${WHITE}"

# ENVIA MOVIMIENTO AL SERVER
  echo "CLIENT_MOVEMENT:$Board_IndexP" | nc -q 0 $SERVER_IP $PORT

done


  print_board

### REMATCH

  read -p "Do you want a Rematch?, press enter to accept, /q to Abort(continues by default)" REMATCH_C

  if [ "$REMATCH_C" = $EXIT_OP ]; then
    echo "Client Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $SERVER_IP $PORT
    break
  fi

  echo "REMATCH" | nc -q 0 $SERVER_IP $PORT

  REMATCH=$(nc -l -p $PORT)

  if [ $REMATCH != "REMATCH" ]; then
    echo "Server Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $SERVER_IP $PORT
    break
  fi

  BOARD=(1 2 3 4 5 6 7 8 9)


done
echo -e "\n\n\t --||:: COMIATS, ESTIMAT USUARI, TORNI D'HORA ::||--"

exit 0

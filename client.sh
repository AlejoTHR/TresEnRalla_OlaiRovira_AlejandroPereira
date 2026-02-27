#!/bin/bash

SERVER_IP=$1
PORT=50000
BOARD=(1 2 3 4 5 6 7 8 9)

RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'


LOG_FILE=$2

EXIT_OP="/q"


SERVER_CHAR="${BLUE}O${WHITE}"
CLIENT_CHAR="${RED}X${WHITE}"



# CONDICIPN ED VICTORIA Y DERROTA LA MANEJA EL server.sh
# FUNCION BOARD DE PLAYER
print_board() {
  echo -e " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} \n"
}

# Checking if the input is a number, is within range, and is not an occupied cell:
check_valid_pos() {
  aux_pos="$1"

	# 0.5.1 Comprova que aux_pos conté només dígits
	if ! echo "$aux_pos" | grep -Eq '^[0-9]+$'; then 
		echo "NOT_VALID"
		return
	fi

	# 0.5.2 Comprova que aux_pos conté un nombre dins del tauler
	if [ "$aux_pos" -lt 1 -o "$aux_pos" -gt 9 ]; then
		echo "NOT_VALID"
		return
	fi

	# 0.5.3 Comprova que aux_pos conté el nombre d'una casella no ocupada
	local array_pos=$((aux_pos - 1))
	local board_char="${BOARD[${array_pos}]}"
	if [ "$board_char" = "$SERVER_CHAR" -o "$board_char" = "$CLIENT_CHAR" ]; then
		echo "NOT_VALID"
		return
	fi

	echo "VALID"
}


### REVISION DE CASILLA POSIBLE



#0.1 MISSATGE DE PRESENTACIÓ
echo -e "\n\t\t--||:: BENVINGUT A TRES EN RATLLA UBU ::||--\n\n"



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

  while (true); do

# DURANTE EL BUCLEDEL JUEGO
	while true; do

# MUESTRA EL BOARD
  print_board

# ESPERA EL TURNO
  echo "Esperant Torn ..."

# RECIBE CASILLA YA ESCOGIDA POR EL SERVSER
  ServerMsg=$(nc -l -p $PORT)
  echo "$ServerMsg" >> $LOG_FILE

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
	BOARD[Board_IndexS]=$SERVER_CHAR
	break

  elif [ $MessageHeader = "BYE" ]; then
	echo "L'Oponent s'ha desconectat" | tee -a $LOG_FILE

  else
	echo "[ERROR] El Server ha enviat un missatge incorrecte" | tee -a $LOG_FILE
	exit 1
  fi

#CAMBIA CASILLA ESCOGIDA POR EL SERVER
  BOARD[Board_IndexS]="$SERVER_CHAR"
  print_board

#TURNO DEL PLAYER ENVIADO AL SERVIDOR
## LEE MOVIMIENTO
  read -p "Posició del Jugador(1-9): " pos
  Board_IndexP=$((pos - 1))

## DETECTA SI LA CASILLA ESTA OCUPADA
  while [ $(check_valid_pos "$pos") != "VALID" ]; do
  	read -p "Posició incorrecta, torna a provar-ho (1-9): " pos
## TRANSFORMAA FORMATO ARRAY
  	Board_IndexP=$((pos - 1))
  done
## ESCRIBE LA FICHA EN EL BOARD
  BOARD[$Board_IndexP]="$CLIENT_CHAR"

# ENVIA MOVIMIENTO AL SERVER
  echo "CLIENT_MOVEMENT:$Board_IndexP" | nc -q 0 $SERVER_IP $PORT
  echo "CLIENT_MOVEMENT:$Board_IndexP" >> $LOG_FILE


done
### PRINTEA BOARD AL FINAL

  print_board

### REMATCH

  read -p "Do you want a Rematch?, press enter to accept, /q to Abort(continues by default)" REMATCH_C

  if [ "$REMATCH_C" = $EXIT_OP ]; then
    echo "Client Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $SERVER_IP $PORT
    break
  fi
## ENVIA REMACTH
  echo "REMATCH" | nc -q 0 $SERVER_IP $PORT
## ESCUCHA REMATCH
  REMATCH=$(nc -l -p $PORT)

  if [ $REMATCH != "REMATCH" ]; then
    echo "Server Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $SERVER_IP $PORT
    break
  fi
## RESETEA REMATCH
  BOARD=(1 2 3 4 5 6 7 8 9)

done
echo -e "\n\n\t --||:: COMIATS, ESTIMAT USUARI, TORNI D'HORA ::||--"

exit 0


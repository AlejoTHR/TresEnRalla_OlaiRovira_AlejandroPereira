#!/bin/bash

if [ $# -lt 2 ]; then
  echo "[ERROR]Invalid number of parameters. Only an IP is required and a Log File route"
  exit 1
fi

# 0.1 Constants i variables de configuració global
CLIENT_IP=$1
PORT=50000
BOARD=(1 2 3 4 5 6 7 8 9)

RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'

LOG_FILE=$2

EXIT_OP="/q"


# 0.2 Definició de la funció que printa el tauler
print_board() {
  echo -e " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
  echo -e "---+---+---"
  echo -e " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} \n"
}

# 0.3 Funció que envia a stdout si s'ha guanyat la partida (echo "WIN" o echo "NONE")
check_win() {
  # = Comprovació de files =
  # Fila 1: posicions 0,1,2
  if [[ "${BOARD[0]}" == "${BOARD[1]}" && "${BOARD[1]}" == "${BOARD[2]}" ]]; then
    echo "WIN"
    return
  fi

  # Fila 2: posicions 3,4,5
  if [[ "${BOARD[3]}" == "${BOARD[4]}" && "${BOARD[4]}" == "${BOARD[5]}" ]]; then
    echo "WIN"
    return
  fi

  # Fila 3: posicions 6,7,8
  if [[ "${BOARD[6]}" == "${BOARD[7]}" && "${BOARD[7]}" == "${BOARD[8]}" ]]; then
    echo "WIN"
    return
  fi

  # = Comprovació de columnes =
  # Columna 1: posicions 0,3,6
  if [[ "${BOARD[0]}" == "${BOARD[3]}" && "${BOARD[3]}" == "${BOARD[6]}" ]]; then
    echo "WIN"
    return
  fi

  # Columna 2: posicions 1,4,7
  if [[ "${BOARD[1]}" == "${BOARD[4]}" && "${BOARD[4]}" == "${BOARD[7]}" ]]; then
    echo "WIN"
    return
  fi

  # Columna 3: posicions 2,5,8
  if [[ "${BOARD[2]}" == "${BOARD[5]}" && "${BOARD[5]}" == "${BOARD[8]}" ]]; then
    echo "WIN"
    return
  fi

  # = Comprovació de diagonals =
  # Diagonal principal: 0,4,8
  if [[ "${BOARD[0]}" == "${BOARD[4]}" && "${BOARD[4]}" == "${BOARD[8]}" ]]; then
    echo "WIN"
    return
  fi

  # Diagonal inversa: 2,4,6
  if [[ "${BOARD[2]}" == "${BOARD[4]}" && "${BOARD[4]}" == "${BOARD[6]}" ]]; then
    echo "WIN"
    return
  fi

  tie_found=1
  for i in "${BOARD[@]}"; do
    if [[ $i != "${RED}X${WHITE}" && $i != "${RED}X${WHITE}" ]]; then
	tie_found=0
	break
    fi
  done

  if [ tie_found -eq 1 ]; then
    echo "TIE"
  fi

  # Si no s'ha detectat cap "WIN", retorna un "NONE"
  echo "NONE"
}



#0.1 MISSATGE DE PRESENTACIÓ
echo -e "\n\t\t--||:: BENVINGUT A TRES EN RATLLA UBU ::||--\n\n"

while (true); do

# 1 Espera connexió
echo "Esperant Connexió"
msg=$(nc -l -p $PORT)

echo "Client tried to connect with message: $msg" | tee -a $LOG_FILE

# 2.1 Si la connexió no és un "HELLO", s'envia un "KO" i es tanca el programa
if [[ "$msg" != "HELLO" ]]; then

  echo "KO" | nc -q 0 $CLIENT_IP $PORT
  echo "Connexió rebutjada" | tee -a $LOG_FILE
  exit 1
fi

# 2.2 Si la connexió és "HELLO", s'envia un "OK" i es continua el programa
if [[ "$msg" == "HELLO" ]]; then
  read -p "Press enter to send OK to the client or pres /q to Abort(continues by default):" ServerResp

# PREGUNTA SI QUIERE ACEPTAR LA PARTIDA
  if [ "$ServerResp" = $EXIT_OP ]; then
    echo "BYE" | nc -q 0 $CLIENT_IP $PORT
    echo "Server Denied Connection" >> $LOG_FILE
    break
  fi

  echo "OK" | nc -q 0 $CLIENT_IP $PORT

  ######echo "OK" | nc -q 0 "10.65.0.51" "50000"
  echo "Client Connected!" | tee -a $LOG_FILE
fi

# 3 Missatge de benvinguda a la partida
# 3.1 Es printa el tauler buit
print_board

# 4 GameLoop
while true; do

  # 4.1 Es demana una posició al jugador servidor
  # pos - guarda linput de lusuari
  read -p "Posició del servidor (1-9): " pos
  board_index=$((pos - 1))

  while [[ "${BOARD[${board_index}]}" == "X" || "${BOARD[${board_index}]}" == "O" ]]; do
  read -p "Posició incorrecta, torna a provar-ho (1-9): " pos
  board_index=$((pos - 1))

  done
  # board_index - guarda el resultat de $(( ... ))


  # assigna "O" a la casella BOARD[...]
    BOARD[$board_index]="${BLUE}O${WHITE}"

  # 4.2 Es comprova si s'ha guanyat (result="WIN" o result="NONE")
  result=$(check_win)
  if [ "$result" = "WIN" ]; then
    # S'envia un "SERVER_WIN" al client
    echo "SERVER_WIN:${board_index}" | nc -q 0 $CLIENT_IP $PORT
    echo "SERVER_WON" >> $LOG_FILE
    echo "Has guanyat!"
    break
  elif [ "$result" = "TIE"]; then
  echo "TIE"
  break
  fi

  # informar al client de la nova posició de moviment:
  echo "SERVER_MOVEMENT:${board_index}" | nc -q 0 $CLIENT_IP $PORT

  # 4.3 Es printa el tauler
  print_board

  # == TORN CLIENT ==

  # 4.4 S'envia al client que comença el seu torn
  echo "CLIENT_TURN" | nc -q 0 $CLIENT_IP $PORT

  # 4.5 Es llegeix el moviment del client
  clientMsg=$(nc -l -p $PORT)

  # Detectar tipus de missatge
  clientHeader=$(echo "$clientMsg" | cut -d ":" -f 1)

  if [ $clientHeader = "CLIENT_MOVEMENT" ]; then
    echo "L'oponent ha mogut peça."

  elif [ $clientHeader = "BYE" ]; then
    echo "L'oponent s'ha desconnectat!" | tee -a $LOG_FILE
  else
    echo "[ERROR] El client ha enviat un missatge incorrecte" | tee -a $LOG_FILE
    exit 1
  fi

  clientMovement=$(echo "$clientMsg" | cut -d ":" -f 2)

  # 4.6 S'actualitza el moviment al tauler
  BOARD[clientMovement]="${RED}X${WHITE}"

  # 4.7 Es comprova si s'ha guanyat (result="WIN" o result="NONE")
  result=$(check_win)
  if [ "$result" = "WIN" ]; then
    # S'envia un "SERVER_WIN" al client
    echo "CLIENT_WIN" | nc -q 0 $CLIENT_IP $PORT
    echo "Has perdut!"
    break
  fi

  # 4.8 Es printa el tauler
  print_board

done

print_board

### REVANCHA
  REMATCH=$(nc -l -p $PORT)

  if [ $REMATCH != "REMATCH" ]; then
    echo "Client Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $CLIENT_IP $PORT
    break
  fi


  read -p "Client wants Rematch, press enter to accept, /q to Abort(continues by default)" REMATCH_S


  if [ "$REMATCH_S" = $EXIT_OP ]; then
    echo "Server Refused Rematch" | tee -a $LOG_FILE
    echo "BYE" | nc -q 0 $CLIENT_IP $PORT
    break
  fi

  echo "REMATCH" | nc -q 0 $CLIENT_IP $PORT

  BOARD=(1 2 3 4 5 6 7 8 9)

done

echo -e "\n\n\t --||:: COMIATS, ESTIMAT USUARI, TORNI D'HORA ::||--"

exit 0

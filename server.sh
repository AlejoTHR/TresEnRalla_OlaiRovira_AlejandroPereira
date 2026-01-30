#!/bin/bash

# 0.1 Constants i variables de configuració global
CLIENT_IP="192.168.1.82"
PORT=64113
BOARD=(1 2 3 4 5 6 7 8 9)

# 0.2 Definició de la funció que printa el tauler
print_board() {
  echo " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
  echo "---+---+---"
  echo " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
  echo "---+---+---"
  echo " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} "
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

  # Si no s'ha detectat cap "WIN", retorna un "NONE"
  echo "NONE"
}


# 1 Espera connexió
msg=$(nc -l -p $PORT)

# 2.1 Si la connexió no és un "HELLO", s'envia un "KO" i es tanca el programa
if [[ "$msg" != "HELLO" ]]; then
  echo "KO" | nc -q 0 $CLIENT_IP $PORT
  exit 1
fi

# 2.2 Si la connexió és "HELLO", s'envia un "OK" i es continua el programa

# 3 Missatge de benvinguda a la partida
# 3.1 Es printa el tauler buit
print_board

# 4 GameLoop
while true; do

  # == TORN SERVIDOR ==

  # 4.1 Es demana una posició al jugador servidor
  # pos - guarda linput de lusuari
  read -p "Posició del servidor (1-9): " pos
  # board_index - guarda el resultat de $(( ... ))
  board_index=$((pos - 1))
  # assigna "O" a la casella BOARD[...]
  BOARD[$board_index]="O"

  # 4.2 Es comprova si s'ha guanyat (result="WIN" o result="NONE")
  result=$(check_win)
  if [[ "$result" == "WIN" ]]; then
    # S'envia un "SERVER_WIN" al client
    echo "SERVER_WIN" | nc -q 0 $CLIENT_IP $PORT
    break
  fi

  # 4.3 Es printa el tauler
  print_board

  # == TORN CLIENT ==

  # 4.4 S'envia al client que comença el seu torn
  # 4.5 Es llegeix el moviment del client
  # 4.6 S'actualitza el moviment al tauler
  # 4.7 Es comprova si s'ha guanyat (result="WIN" o result="NONE")
  # 4.8 Es printa el tauler
  print_board

done

exit 0
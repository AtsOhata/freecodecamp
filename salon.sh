#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -c"

SERVICES=$($PSQL "select service_id, name from services")

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then echo -e "\nI could not find that service. What would you like today?"
  fi

  FLAG=1
  while [ $FLAG -eq 1 ]
  do
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
      then echo "$SERVICE_ID) $SERVICE_NAME"
      fi
    done
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      A=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
      CHOSEN_SERVICE_ID=$(echo "$A" | awk 'NR==3 {print $1}')
      if [[ $CHOSEN_SERVICE_ID =~ ^[0-9]+$ ]]
      then
        FLAG=0
      fi
    fi
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER=$($PSQL "select customer_id, name from customers where phone = '$CUSTOMER_PHONE'")
  if [[ $(echo "$CUSTOMER" | awk 'NR==3 {print $1}') == "(0" ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$(echo "$CUSTOMER" | awk 'NR==3 {print $1}')
  else
    CUSTOMER_ID=$(echo "$CUSTOMER" | awk 'NR==3 {print $1}')
    CUSTOMER_NAME=$(echo "$CUSTOMER" | awk 'NR==3 {print $3}')
  fi

  echo -e "\nInput appointment time"
  read SERVICE_TIME
  echo $CUSTOMER_ID $CUSTOMER_NAME $SERVICE_TIME
  RESULT2=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $CHOSEN_SERVICE_ID, '$SERVICE_TIME')")

  SERVICE=$($PSQL "select name from services where service_id = $CHOSEN_SERVICE_ID")
  CUSTOMER_SERVICE_NAME=$(echo "$SERVICE" | awk 'NR==3 {print $1}')

  echo -e "\nI have put you down for a $CUSTOMER_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU
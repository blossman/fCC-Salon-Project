#!/bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~ Bloss's Buzzes ~~~\n"
echo -e "Welcome to the salon, how can I help you?\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo $SERVICE_SELECTED
  if [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #get Phone Number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #if not in system
    if [[ -z $CUSTOMER_NAME ]]
    then
      #get name
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      #insert customer row
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #Ask time
    echo -e "\nWhen would you like your $(echo $SERVICE_SELECTED | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME| sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    #Create appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    #print confirmation
    echo -e "\nI have put you down for a $(echo $SERVICE_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME| sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU
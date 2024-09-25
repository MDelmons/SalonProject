#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

FIRST_TIME="Welcome to My Salon, how can I help you?"

WELCOME(){
  echo -e "$1\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | sed 's/ |/)/g'
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      WELCOME "I could not find that service. What would you like today?"
    else
      MEETING $SERVICE_ID_SELECTED $SERVICE_NAME
    fi
  else
    WELCOME "Insert a number input"
  fi
}

MEETING(){
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo I don't have a record for that phone number, what's your name?
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo What time would you like your $2, $CUSTOMER_NAME?
    read SERVICE_TIME
    $PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$1,'$SERVICE_TIME')"
    echo "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    echo What time would you like your $2, $CUSTOMER_NAME?
    read SERVICE_TIME
    $PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$1,'$SERVICE_TIME')"
    echo "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

WELCOME "$FIRST_TIME"

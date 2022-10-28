#!/bin/bash

PSQL="psql -A -t --csv --username=freecodecamp --dbname=salon -c"

# first figure out the list of services
SERVICES=$($PSQL "select service_id, name from services")


function book_service() {
  SERVICE_ID=$1
  SERVICE_NAME=$2
  echo -e "\nbooking service $SERVICE_NAME, please enter phone:"
  read CUSTOMER_PHONE
  CUSTOMER_INFO=$($PSQL "select name,customer_id from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_INFO ]]
  then
    echo "name?"
    read CUSTOMER_NAME
    NAME_INSERT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    if [[ $NAME_INSERT != "INSERT 0 1" ]]
    then
      echo "insert failed?"
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=`echo $CUSTOMER_INFO | sed 's/,.*$//'`
    CUSTOMER_ID=`echo $CUSTOMER_INFO | sed 's/^.*,//'`
  fi
  echo we are set up for $CUSTOMER_NAME $CUSTOMER_ID $CUSTOMER_PHONE service $SERVICE_ID $SERVICE_NAME
  echo "what time?"
  read SERVICE_TIME
  APPT_INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID','$SERVICE_ID', '$SERVICE_TIME')")
  if [[ $APPT_INSERT != "INSERT 0 1" ]]
  then
      echo "appt insert failed? $APPT_INSERT"
  else echo I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.
  fi

}

function get_service () {
  echo $1
  echo "$SERVICES" | while IFS="," read SERVICE_ID NAME
  do
    echo "$SERVICE_ID)" $NAME
  done
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
    if [[ ! -z $SERVICE_NAME ]]
    then
      book_service $SERVICE_ID_SELECTED $SERVICE_NAME
    else
      get_service "Please try again"
    fi
  else
    get_service "Please try again"
  fi
}

get_service "Your pleasure?"



#!/bin/bash

# check arg provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# psql conn helper (quiet, no headers/formatting)
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

# detect input type: number vs symbol/name
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="atomic_number=$1"
else
  CONDITION="symbol='$1' OR name='$1'"
fi

# query join across elements/properties/types
RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
JOIN properties p USING(atomic_number) 
JOIN types t USING(type_id) 
WHERE $CONDITION;")

# handle not found vs format pretty output
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
else
  echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done
fi

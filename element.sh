#! /bin/bash

# Program to display information about certain elements of the periodic table

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $# != 1 ]]
then
  echo -e "Please provide an element as an argument."  
  exit
else
  ARG=$1
  if [[ $ARG =~ ^[0-9]+$ ]] # check if arg is number
  then # if number then search only atomic num, this is due to differing data types
    ATOM_NUM=$($PSQL "select atomic_number from elements where atomic_number = $ARG")
  else # if not a number then search sybmol or name, since they are varchars
    ATOM_NUM=$($PSQL "select atomic_number from elements where symbol='$ARG' or name='$ARG'")
  fi # end regex's

  if [[ -z $ATOM_NUM ]] # if atom num empty then no element found
  then
    echo "I could not find that element in the database."
  else
    # need atom_num, name, symbol, type, mass, name, melt_point, and boil_point;
    PROPERTIES=$($PSQL "select name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements inner join properties using(atomic_number) inner join types using(type_id) where atomic_number = $ATOM_NUM")
    echo $PROPERTIES | sed 's/|/ /g' | while read NAME SYMBOL TYPE ATOM_MASS MELT_PNT BOIL_PNT
    do
      echo "The element with atomic number $ATOM_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOM_MASS amu. $NAME has a melting point of $MELT_PNT celsius and a boiling point of $BOIL_PNT celsius."
    done
  fi # end [[ -z atom num ]]

fi # end [[ $# != 1 ]]

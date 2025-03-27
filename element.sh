#!/bin/bash
# element.sh - Periodic Table Element Lookup
# Usage: ./element.sh [atomic_number|symbol|name]

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to validate input
validate_input() {
  if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
    exit 0
  fi
}

# Function to query database
query_element() {
  local input=$1
  if [[ $input =~ ^[0-9]+$ ]]; then
    $PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
           FROM elements e 
           JOIN properties p ON e.atomic_number = p.atomic_number 
           JOIN types t ON p.type_id = t.type_id 
           WHERE e.atomic_number = $input"
  elif [[ $input =~ ^[A-Za-z]{1,2}$ ]]; then
    $PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
           FROM elements e 
           JOIN properties p ON e.atomic_number = p.atomic_number 
           JOIN types t ON p.type_id = t.type_id 
           WHERE e.symbol = INITCAP('$input')"
  else
    $PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
           FROM elements e 
           JOIN properties p ON e.atomic_number = p.atomic_number 
           JOIN types t ON p.type_id = t.type_id 
           WHERE e.name = '$input'"
  fi
}

# Function to display results
display_results() {
  local ELEMENT_INFO=$1
  if [[ -z $ELEMENT_INFO ]]; then
    echo "I could not find that element in the database."
    exit 0
  fi

  echo "$ELEMENT_INFO" | while IFS='|' read atomic_number name symbol type atomic_mass melting_point boiling_point; do
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
  done
}

# Main execution
validate_input "$1"
ELEMENT_INFO=$(query_element "$1")
display_results "$ELEMENT_INFO"
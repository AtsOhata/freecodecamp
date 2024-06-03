#!/bin/bash

SECRET_NUMBER=$((1 + $RANDOM % 1000))

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER=$($PSQL "select user_name, games_played, best_game from users where user_name = '$USERNAME'")
IFS='|' read USER_NAME GAMES_PLAYED BEST_GAME <<< "$USER"
if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "insert into users (user_name) values ('$USERNAME')")
else
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
NUMBER_OF_GUESSES=1
while [[ $SECRET_NUMBER != $USER_GUESS ]]
do
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $USER_GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  read USER_GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

GAMES_PLAYED=$(($GAMES_PLAYED + 1))
UPDATE_RESULT=$($PSQL "update users set games_played = $GAMES_PLAYED where user_name = '$USERNAME'")

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  UPDATE_RESULT2=$($PSQL "update users set best_game = $NUMBER_OF_GUESSES where user_name = '$USERNAME'")
fi

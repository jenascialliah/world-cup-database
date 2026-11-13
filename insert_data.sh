
#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line.

# Clear existing data
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;" > /dev/null

# Read games.csv line by line
while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the header
  if [[ $YEAR == "year" || -z $YEAR ]]
  then
    continue
  fi

  OPPONENT_GOALS=${OPPONENT_GOALS//$'\r'/}

  # Add unique teams
  $PSQL "
    INSERT INTO teams(name)
    VALUES ('$WINNER'), ('$OPPONENT')
    ON CONFLICT (name) DO NOTHING;

    INSERT INTO games(
      year,
      round,
      winner_id,
      opponent_id,
      winner_goals,
      opponent_goals
    )
    VALUES (
      $YEAR,
      '$ROUND',
      (SELECT team_id FROM teams WHERE name='$WINNER'),
      (SELECT team_id FROM teams WHERE name='$OPPONENT'),
      $WINNER_GOALS,
      $OPPONENT_GOALS
    );
  " > /dev/null

done < games.csv

echo "World Cup data imported successfully."

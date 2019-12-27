#!/bin/bash

REPO_PATH=$1
UPDATE_CHART=$2
FILES_FOR_UPDATING=("${@:3}")

CHANGE_FILE=$(git diff-tree --no-commit-id --name-only -r HEAD)

should_update=false
for file in ${FILES_FOR_UPDATING[*]}
do
  if echo "$CHANGE_FILE" | grep "$file"
  then
    should_update=true
    break
  fi
done

if $should_update
then
  helm dep update "$REPO_PATH/$UPDATE_CHART"
  helm package "$REPO_PATH/$UPDATE_CHART"
  helm repo index .
else
  echo "update hqo-app no requeired"
fi

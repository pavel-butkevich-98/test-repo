#!/bin/bash

git add .

git status

COMMIT_MESSAGE="Commit updates index.yaml and adds new charts: "$(git status --porcelain | grep "^A" | cut -c 4- | sed ':a;N;$!ba;s/\n/, /g')

git commit -m "$COMMIT_MESSAGE"

git push

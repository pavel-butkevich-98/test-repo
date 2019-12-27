#!/bin/bash

set -o

# Path to charts repo
REPO_PATH=$1
# Path to charts in repo
CHARTS_PATH=$2
# Commit hash for develover charts versions
DEVELOPER_VERSION=$3
# Charts that should be updated always
FORCE_UPDATED_CHARTS=("${@:4}")

CHARTS_DIRS=$(ls "$REPO_PATH/$CHARTS_PATH")
CHANGED_FILES=$(cd "$REPO_PATH" && git diff-tree --no-commit-id --name-only -r HEAD)
UPDATED_CHARTS=()

# Find updated charts
for CHART in $CHARTS_DIRS
do
    if echo "$CHANGED_FILES" | grep "$CHARTS_PATH/$CHART/"; then
        UPDATED_CHARTS+=("$CHART")
    fi
done

# Update repo index
if [ ${#UPDATED_CHARTS[@]} -gt 0 ]; then
    UPDATED_CHARTS+=("${FORCE_UPDATED_CHARTS[@]}")
fi

# Package updated charts
for CHART in "${UPDATED_CHARTS[@]}"
do
    PACKAGE_ARGS=()

    if [[ -n $DEVELOPER_VERSION ]]; then
        CHART_VERSION=$(< "$REPO_PATH/$CHARTS_PATH/$CHART/Chart.yaml" grep version | sed -e 's/version: //g')
        PACKAGE_ARGS=('--version' "$CHART_VERSION-$DEVELOPER_VERSION")
    fi

    helm dep update "$REPO_PATH/$CHARTS_PATH/$CHART"
    helm package "$REPO_PATH/$CHARTS_PATH/$CHART" "${PACKAGE_ARGS[@]}"
done

# Update repo index
if [ ${#UPDATED_CHARTS[@]} -gt 0 ]; then
    helm repo index .
fi

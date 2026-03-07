#!/bin/bash

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <org_name> <output_file>"
    exit 1
fi

ORG_NAME=$1
OUTPUT_FILE=$2

read -p "Enter GitHub Username: " USERNAME
read -s -p "Enter GitHub Token: " TOKEN
echo ""

echo "Fetching repositories from organization: $ORG_NAME"
> "$OUTPUT_FILE"

PAGE=1

while true
do
    REPOS=$(curl -s -u "$USERNAME:$TOKEN" \
    "https://api.github.com/orgs/$ORG_NAME/repos?per_page=100&page=$PAGE" | jq -r '.[].name')

    [ -z "$REPOS" ] && break

    for REPO in $REPOS
    do
        echo "Checking repository: $REPO"

        STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -u "$USERNAME:$TOKEN" \
        "https://api.github.com/repos/$ORG_NAME/$REPO/commits")

        if [ "$STATUS" -eq 409 ]; then
            echo "$REPO" >> "$OUTPUT_FILE"
            echo "Empty repo found: $REPO"
        fi
    done

    ((PAGE++))
done

echo ""
echo "Empty repositories saved to: $OUTPUT_FILE"
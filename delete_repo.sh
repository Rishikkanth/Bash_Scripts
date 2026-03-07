#!/bin/bash

# Check input
if [ $# -ne 1 ]; then
    echo "Usage: $0 <repo_file>"
    exit 1
fi

REPO_FILE=$1

if [ ! -f "$REPO_FILE" ]; then
    echo "File not found: $REPO_FILE"
    exit 1
fi

read -p "Enter GitHub Username: " USERNAME
read -s -p "Enter GitHub Token: " TOKEN
echo ""

echo "Repositories that will be deleted:"
cat "$REPO_FILE"
echo ""

read -p "Are you sure you want to DELETE these repositories? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deletion cancelled."
    exit 0
fi

while IFS= read -r REPO
do
    [ -z "$REPO" ] && continue

    echo "Deleting repository: $REPO"

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X DELETE \
        -u "$USERNAME:$TOKEN" \
        "https://api.github.com/repos/$USERNAME/$REPO")

    if [ "$RESPONSE" -eq 204 ]; then
        echo "SUCCESS: Deleted $REPO"
    else
        echo "FAILED: Could not delete $REPO (HTTP $RESPONSE)"
    fi

    echo "---------------------------"

done < "$REPO_FILE"

echo "Deletion process completed."

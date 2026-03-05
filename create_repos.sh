#!/bin/bash

# Check if repo list file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <repo_list_file>"
    exit 1
fi

REPO_FILE=$1

# Check if repo file exists
if [ ! -f "$REPO_FILE" ]; then
    echo "Error: File '$REPO_FILE' not found!"
    exit 1
fi

# Prompt for GitHub username
read -p "Enter GitHub Username: " USERNAME

# Prompt for GitHub token (hidden)
read -s -p "Enter GitHub Token: " TOKEN
echo ""

while IFS= read -r REPO
do
    # Skip empty lines
    [ -z "$REPO" ] && continue

    echo "Creating repository: $REPO"

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -u "$USERNAME:$TOKEN" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO\"}")

    if [ "$RESPONSE" -eq 201 ]; then
        echo "SUCCESS: Repository '$REPO' created"
    elif [ "$RESPONSE" -eq 422 ]; then
        echo "FAILED: Repository '$REPO' already exists"
    elif [ "$RESPONSE" -eq 401 ]; then
        echo "ERROR: Authentication failed"
        exit 1
    else
        echo "ERROR: Failed to create '$REPO' (HTTP $RESPONSE)"
    fi

    echo "----------------------------------"

done < "$REPO_FILE"

#echo "Process completed."

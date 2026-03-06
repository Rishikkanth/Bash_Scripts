#!/bin/bash

# Check if repo list file is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo_list_file> <organization_name>"
    exit 1
fi

REPO_FILE=$1
ORG_NAME=$2

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

# Save current directory
BASE_DIR=$(pwd)

# Arrays to track success and failures
success_repos=()
failed_repos=()

while IFS= read -r REPO
do
    # Skip empty lines
    [ -z "$REPO" ] && continue

    echo "----------------------------------"
    echo "Processing repository: $REPO"

    # Remove trailing .git if already present for constructing URL
    if [[ "$REPO" == *.git ]]; then
        REMOTE_REPO="${REPO%.git}"
    else
        REMOTE_REPO="$REPO"
    fi

    # Check if local directory exists
    if [ ! -d "$BASE_DIR/$REPO" ]; then
        echo "ERROR: Local directory '$REPO' does not exist"
        failed_repos+=("$REPO (local missing)")
        continue
    fi

    cd "$BASE_DIR/$REPO" || { 
        echo "ERROR: Cannot cd into '$REPO'" 
        failed_repos+=("$REPO (cd failed)")
        continue
    }

    # Push all branches, tags, and refs
    git push --mirror "https://$USERNAME:$TOKEN@github.com/$ORG_NAME/$REMOTE_REPO.git"
    if [ $? -eq 0 ]; then
        echo "SUCCESS: '$REPO' pushed successfully"
        success_repos+=("$REPO")
    else
        echo "FAILED: '$REPO' push failed"
        failed_repos+=("$REPO (push failed)")
    fi

    # Return to base directory
    cd "$BASE_DIR"

done < "$REPO_FILE"

# Summary
echo "=================================="
echo "PROCESS COMPLETED"
echo "Successful repositories:"
for repo in "${success_repos[@]}"; do
    echo "  - $repo"
done

echo "Failed repositories:"
for repo in "${failed_repos[@]}"; do
    echo "  - $repo"
done
echo "=================================="

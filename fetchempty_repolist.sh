$ cat clone_repo.sh
#!/bin/bash

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <output_file>"
    exit 1
fi

OUTPUT_FILE=$1

read -p "Enter GitHub Username: " USERNAME
read -s -p "Enter GitHub Token: " TOKEN
echo ""

echo "Fetching repositories from user: $USERNAME"
> "$OUTPUT_FILE"

PAGE=1

while true
do
    REPOS=$(curl -s -u "$USERNAME:$TOKEN" \
    "https://api.github.com/users/$USERNAME/repos?per_page=100&page=$PAGE" \
    | grep '"name":' | cut -d '"' -f4)

    [ -z "$REPOS" ] && break

    for REPO in $REPOS
    do
        echo "Checking repository: $REPO"

        STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -u "$USERNAME:$TOKEN" \
        "https://api.github.com/repos/$USERNAME/$REPO/commits")

        if [ "$STATUS" -eq 409 ]; then
            echo "$REPO" >> "$OUTPUT_FILE"
            echo "Empty repo found: $REPO"
        fi
    done

    ((PAGE++))
done

echo ""
echo "Empty repositories saved to: $OUTPUT_FILE"

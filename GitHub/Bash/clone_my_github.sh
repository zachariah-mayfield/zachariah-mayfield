#!/bin/bash

# Target directory to clone all repositories into
TARGET_DIR="/Users/zachariah-mayfield/GitHub/Main"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Change to the target directory
cd "$TARGET_DIR" || { echo "Failed to cd into $TARGET_DIR"; exit 1; }

# Get the list of all repositories for the authenticated user
echo "Fetching repository list from GitHub..."
gh repo list zachariah-mayfield --limit 1000 --json name,sshUrl --jq '.[] | .sshUrl' | while read -r repo_url; do
    # Extract the repo name from the URL
    repo_name=$(basename "$repo_url" .git)

    # Clone if the repo doesn't already exist
    if [ ! -d "$repo_name" ]; then
        echo "Cloning $repo_name..."
        git clone "$repo_url"
    else
        echo "$repo_name already exists. Skipping..."
    fi
done

echo "✅ Done cloning repositories."

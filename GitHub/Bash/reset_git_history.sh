#!/bin/bash

# Path to your repo
REPO_PATH="/Path/to/your/GitHub/Repository"

# Name of the new branch (e.g., 'main')
NEW_BRANCH="main"

# Navigate to the repo
cd "$REPO_PATH" || {
  echo "Directory not found: $REPO_PATH"
  exit 1
}

echo "Resetting Git history in: $REPO_PATH"

# Ensure there are no staged changes
git reset

# Create a new orphan branch (no history)
git checkout --orphan temp-clean-history

# Add all files and commit
git add -A
git commit -m "Reset commit history: This is the initial commit with current state. This commit resets the history. 
All previous history has been removed. This was done to clean up the repository. This is the only commit in history. 
This commit is the new starting point for the repository since it will now be a public repository."

# Delete the old main branch
git branch -D "$NEW_BRANCH"

# Rename the new branch to 'main'
git branch -m "$NEW_BRANCH"

# Force push to origin
git push -f origin "$NEW_BRANCH"

echo "✅ Git history reset complete. Only the current state is now in history."

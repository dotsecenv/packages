#!/bin/bash
set -e

echo "WARNING: This will delete ALL history and files in $(pwd)"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# 1. Get Remote URL
REMOTE_URL=$(git remote get-url origin || echo "")
if [ -z "$REMOTE_URL" ]; then
    echo "Error: Could not determine remote URL."
    exit 1
fi
echo "Detected remote: $REMOTE_URL"

# 1.5 Delete Tags
echo "Deleting remote tags..."
git fetch --tags
TAGS=$(git tag -l)
if [ -n "$TAGS" ]; then
    echo "Found tags: $TAGS"
    # Delete tags from remote
    echo "$TAGS" | xargs -n 1 git push --delete origin || echo "Warning: Failed to delete some tags or verification failed."
    # Delete local tags
    echo "$TAGS" | xargs -n 1 git tag -d || echo "Warning: Failed to delete some tags or verification failed."
else
    echo "No tags found."
fi

# 2. Backup essential files
echo "Backing up essential files..."
TMP_DIR=$(mktemp -d)
cp -r .github .gitignore CNAME key.asc README.md "$TMP_DIR/"

# 3. Nuke everything
echo "Removing all files..."
rm -rf ./*
#rm -rf ./.git
rm -rf ./.github

# 4. Create fresh branch
git checkout --orphan fresh

# 5. Restore
echo "Restoring files..."
cp -r "$TMP_DIR"/. .
rm -rf "$TMP_DIR"

# 5. Re-init
git add -A
git commit -m "Initial commit"
git branch -D main
git branch -m main

echo "Pushing to remote..."
git branch --set-upstream-to=origin/main main
git push -f origin main

echo "Done!"

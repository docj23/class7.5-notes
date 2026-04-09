#!/bin/bash

# --- CONFIGURATION ---
TARGET_DIR="$HOME/Documents/TheoWAF/class7.5/GCP/Terraform"
WEEK_DIR="$TARGET_DIR/my-first-terraform-project"

echo "--- STEP 1: TARGET DIRECTORY CHECK ---"
if [ -d "$TARGET_DIR" ]; then
    echo "Target directory '$TARGET_DIR' exists."
else
    mkdir -p "$TARGET_DIR"
    echo "Warning: TheoWAF Class 7.5 directory did not exist but was successfully created, are you sure you ran the installs script?"
fi

echo -e "\n--- STEP 2: TOOLING CHECK (VS CODE + JQ) ---"

# VS Code check
if command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code is installed."
else
    echo "ERROR: Visual Studio Code ('code') is not installed or not in PATH."
    exit 1
fi

# jq check
if command -v jq >/dev/null 2>&1; then
    echo "jq is installed."
else
    echo "ERROR: jq is not installed."
    echo "Did you run the install script?"
    exit 1
fi

echo -e "\n--- STEP 3: JSON FILE CHECK ---"
SA_TOKEN=$(find "$TARGET_DIR" -maxdepth 1 -type f -name "*.json" | head -n 1)

if [ -n "$SA_TOKEN" ]; then
    echo "Found JSON file: $(basename "$SA_TOKEN")"
else
    echo "ERROR: No JSON files found in $TARGET_DIR."
    exit 1
fi

echo -e "\n--- STEP 4: TERRAFORM CHECK ---"
if command -v terraform >/dev/null 2>&1; then
    TF_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version')

    echo "Current Terraform Version: $TF_VERSION"

    TF_MAJOR=$(echo "$TF_VERSION" | jq -R 'split(".")[0] | tonumber')
    TF_MINOR=$(echo "$TF_VERSION" | jq -R 'split(".")[1] | tonumber')

    if [ "$TF_MAJOR" -lt 1 ] || { [ "$TF_MAJOR" -eq 1 ] && [ "$TF_MINOR" -lt 5 ]; }; then
        echo "WARNING: Terraform version is below 1.5."
        echo "Recommended: Terraform version 1.5 or newer."
    else
        echo "Terraform version meets recommendation (1.5+)."
    fi
else
    echo "ERROR: Terraform is not installed."
    exit 1
fi

echo -e "\n--- STEP 5: DOWNLOAD .GITIGNORE ---"
if curl --ssl-no-revoke -s -o "$TARGET_DIR/.gitignore" https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/refs/heads/main/101825/.gitignore; then
    echo ".gitignore downloaded to $TARGET_DIR"
else
    echo "ERROR: Failed to download .gitignore"
    exit 1
fi

echo -e "\n--- STEP 6: SETUP PROJECT DIRECTORY ---"
mkdir -p "$WEEK_DIR"
echo "Created directory: $WEEK_DIR"

# Copy JSON file
cp "$SA_TOKEN" "$WEEK_DIR/"
echo "Copied JSON file to $WEEK_DIR"

# Copy .gitignore
cp "$TARGET_DIR/.gitignore" "$WEEK_DIR/"
echo "Copied .gitignore to $WEEK_DIR"

echo -e "\n--- FINISHED ---"
echo "Your Terraform project directory is ready:"
echo "$WEEK_DIR"
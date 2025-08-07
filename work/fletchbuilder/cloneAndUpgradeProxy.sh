#!/bin/bash

# This script clones a project from Azure DevOps, checks out the develop branch,
# and creates a new feature branch for a Mule Runtime upgrade.

# Check if a project name is provided as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

# Set the project name from the first argument.
PROJECT_NAME=$1

# Clone the repository from Azure DevOps.
git clone "https://FB-Integration@dev.azure.com/FB-Integration/Mule-Integrations/_git/$PROJECT_NAME"

# Change into the project directory.
cd "$PROJECT_NAME"

# Checkout the develop branch.
git checkout develop

# Pull the latest changes from the develop branch.
git pull

# Check if the feature branch already exists.
if git rev-parse --verify feature/MuleRuntimeUpgrade4.9 >/dev/null 2>&1; then
  # If the branch exists, check it out.
  echo "Branch feature/MuleRuntimeUpgrade4.9 already exists."
  git checkout feature/MuleRuntimeUpgrade4.9
else
  # If the branch does not exist, create it.
  echo "Branch feature/MuleRuntimeUpgrade4.9 does not exist. Creating it now."
  git checkout -b feature/MuleRuntimeUpgrade4.9
fi

# Step 1: Update assetVersion in policy files
echo "--- Step 1: Updating asset versions in policy files ---"
for file in configuration/jwt-validation-policy-*.json; do
  sed -i 's/"assetVersion": "1.3.6"/"assetVersion": "1.5.0"/' "$file"
done
sed -i 's/"assetVersion": "1.3.4"/"assetVersion": "1.4.0"/' "configuration/rate-limiting-policy.json"
echo "[X] Step 1: Policy files updated."

# Step 2: Delete Jenkinsfile if it exists
echo "--- Step 2: Deleting Jenkinsfile ---"
if [ -f "Jenkinsfile" ]; then
    rm Jenkinsfile
    echo "[X] Step 2: Jenkinsfile deleted."
else
    echo "INFO: Jenkinsfile not found, skipping deletion."
fi

# Step 3: Ask the user if they want to open the project in VS Code.
echo "--- Step 3: Open VSCode ---"
read -p "Do you want to open the project in Visual Studio Code? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  code .
fi

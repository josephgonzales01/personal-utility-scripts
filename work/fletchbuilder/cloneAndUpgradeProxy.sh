#!/bin/bash

# This script clones a project from Azure DevOps, lists all available branches,
# lets the user select one by number, and creates a new feature branch for a Mule Runtime upgrade.

# Check if a project name is provided as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

# Set the project name from the first argument.
PROJECT_NAME=$1

# Clone the repository from Azure DevOps.
echo "--- Step 1: Cloning the project $PROJECT_NAME ---"
git clone "https://FB-Integration@dev.azure.com/FB-Integration/Mule-Integrations/_git/$PROJECT_NAME"

# Change into the project directory.
cd "$PROJECT_NAME"

# Fetch all branches
git fetch --all

# Get list of remote branches (excluding HEAD)
branches=$(git branch -r | grep -v HEAD | sed 's/origin\///')

# Convert to array
IFS=$'\n' read -r -d '' -a branch_array <<< "$branches"

# Display branches with numbers
echo "Existing branches:"
for i in "${!branch_array[@]}"; do
  echo "$((i+1)). ${branch_array[i]}"
done

# Prompt user to select a branch
while true; do
  read -p "Select the base branch for the new RuntimeUpgrade branch will be based on (1-${#branch_array[@]}): " branch_num
  if [[ $branch_num -ge 1 && $branch_num -le ${#branch_array[@]} ]]; then
    break
  else
    echo "Invalid selection. Please enter a number between 1 and ${#branch_array[@]}."
  fi
done

# Get selected branch name
SELECTED_BRANCH=$(echo "${branch_array[$((branch_num-1))]}" | xargs)

# Checkout the selected branch and Pull the latest changes.
echo "--- Step 2: Checkout $SELECTED_BRANCH and pull the latest changes ---"
git checkout "$SELECTED_BRANCH"
git pull

echo "--- Step 3: Create a new branch feature/MuleRuntimeUpgrade4.9 if it doesn't exist ---"
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

# Update assetVersion in policy files
echo "--- Step 4: Updating assetVersion in jwt-validation-policy-*.json files ---"
for file in configuration/jwt-validation-policy-*.json; do
  sed -i 's/"assetVersion": "1.3.6"/"assetVersion": "1.5.0"/' "$file"
done
echo "--- Step 5: Updating assetVersion in rate-limiting-policy.json ---"
sed -i 's/"assetVersion": "1.3.4"/"assetVersion": "1.4.0"/' "configuration/rate-limiting-policy.json"

# Delete Jenkinsfile if it exists
echo "--- Step 6: Deleting Jenkinsfile ---"
if [ -f "Jenkinsfile" ]; then
    rm Jenkinsfile
else
    echo "INFO: Jenkinsfile not found, skipping deletion."
fi

# Ask the user if they want to open the project in VS Code.
read -p "Do you want to open the project in VS Code? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  code .
fi

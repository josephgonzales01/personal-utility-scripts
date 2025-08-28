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

# Get the directory where this script is located (before changing directories)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/Mule-Integrations-Templates"

# Clone the repository from Azure DevOps.
echo "--- Step 1: Cloning the project $PROJECT_NAME ---"
git clone "https://FB-Integration@dev.azure.com/FB-Integration/Mule-Integrations/_git/$PROJECT_NAME"

# Change into the project directory.
cd "$PROJECT_NAME"

# Fetch all branches
git fetch --all

# Get list of remote branches (excluding HEAD)
branches=$(git branch -r | grep -v HEAD | sed 's/ *origin\///')

# Convert to array
IFS=$'\n' read -r -d '' -a branch_array <<< "$branches"

# Display branches with numbers and last commit datetime
echo "Existing branches:"
for i in "${!branch_array[@]}"; do
  branch_name="${branch_array[i]}"
  # Get the last commit datetime for this branch
  last_commit_datetime=$(git log -1 --format="%ad" --date=short "origin/${branch_name}" 2>/dev/null || echo "Unknown")
  echo "$((i+1)). ${branch_name} (Last commit: ${last_commit_datetime})"
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

# Delete Jenkinsfile if it exists
echo "--- Step 4: Deleting Jenkinsfile ---"
if [ -f "Jenkinsfile" ]; then
    rm Jenkinsfile
else
    echo "INFO: Jenkinsfile not found, skipping deletion."
fi

# Step 5: Update main-pipeline.yml
echo "--- Step 5: Updating main-pipeline.yml ---"
if [ -f "main-pipeline.yml" ]; then
    sed -i "s|ref:.*|ref: refs/tags/jdk17-maven3.8.6-1.1|" main-pipeline.yml
    sed -i "s|imagename:.*|imagename: localhost:5000/maven-mule-jdk17-maven3.8.6:1.0|" main-pipeline.yml
    sed -i "s|jdkVersion:.*|jdkVersion: '17'|" main-pipeline.yml
else
    echo "INFO: main-pipeline.yml not found. Downloading from Azure DevOps repository..."
    
    # Available business groups
    business_groups=("BP" "DS" "FBAU" "FI" "GT")
    
    # Display business groups with numbers
    echo "Available Business Groups:"
    for i in "${!business_groups[@]}"; do
        echo "$((i+1)). ${business_groups[i]}"
    done
    
    # Prompt user to select a business group
    while true; do
        read -p "Select the Business Group for this proxy (1-${#business_groups[@]}): " bg_num
        if [[ $bg_num -ge 1 && $bg_num -le ${#business_groups[@]} ]]; then
            break
        else
            echo "Invalid selection. Please enter a number between 1 and ${#business_groups[@]}."
        fi
    done
    
    # Get selected business group
    SELECTED_BG="${business_groups[$((bg_num-1))]}"
    echo "Selected Business Group: $SELECTED_BG"
    
    echo "Getting main-pipeline.yml for business group: $SELECTED_BG"
    
    # Check if templates directory already exists
    if [ -d "$TEMPLATES_DIR" ]; then
        echo "Templates directory found. Updating to latest version..."
        cd "$TEMPLATES_DIR"
        
        # Fetch latest changes and checkout the correct branch
        git fetch --all 2>/dev/null
        git checkout feature/jdk17-maven3.8.6 2>/dev/null || git checkout main 2>/dev/null || echo "Using current branch"
        git pull 2>/dev/null || echo "Pull completed"
        
        cd "$OLDPWD"
    else
        echo "Templates directory not found. Cloning templates from FB-Integration/Mule-Integrations repository..."
        
        # Clone the Mule-Integrations repository to get the templates
        if git clone "https://FB-Integration@dev.azure.com/FB-Integration/Mule-Integrations/_git/Mule-Integrations" "$TEMPLATES_DIR" 2>/dev/null; then
            cd "$TEMPLATES_DIR"
            
            # Checkout the correct branch
            git checkout feature/jdk17-maven3.8.6 2>/dev/null || git checkout main 2>/dev/null || echo "Using default branch"
            
            cd "$OLDPWD"
            echo "Successfully cloned templates repository"
        else
            echo "ERROR: Failed to clone templates repository. Please manually add the file from:"
            echo "https://dev.azure.com/FB-Integration/Mule-Integrations/_git/Mule-Integrations?path=/templates/Mule%20Proxy/${SELECTED_BG}&version=GBfeature/jdk17-maven3.8.6&_a=contents"
            return 1
        fi
    fi
    
    # Check if the specific business group pipeline file exists
    PIPELINE_FILE="$TEMPLATES_DIR/templates/Mule Proxy/${SELECTED_BG}/main-pipeline.yml"
    if [ -f "$PIPELINE_FILE" ]; then
        # Copy the file to the project directory
        cp "$PIPELINE_FILE" "main-pipeline.yml"
        echo "Successfully copied main-pipeline.yml for business group: $SELECTED_BG"
    else
        echo "ERROR: Pipeline file not found at: $PIPELINE_FILE"
        echo "Available business group directories:"
        ls -la "$TEMPLATES_DIR/templates/Mule Proxy/" 2>/dev/null || echo "Templates directory not found"
        echo ""
        echo "Please manually add the file from:"
        echo "https://dev.azure.com/FB-Integration/Mule-Integrations/_git/Mule-Integrations?path=/templates/Mule%20Proxy/${SELECTED_BG}&version=GBfeature/jdk17-maven3.8.6&_a=contents"
    fi
fi

# Update assetVersion in policy files (moved to after main-pipeline.yml handling to avoid directory change issues)
echo "--- Step 6: Updating assetVersion in jwt-validation-policy-*.json files ---"
for file in configuration/jwt-validation-policy-*.json; do
  if [ -f "$file" ]; then
    # Update JWT validation policy to version 1.5.0 regardless of current version
    # First check if the file contains an assetVersion field
    if grep -q '"assetVersion"' "$file"; then
      # Use sed to update the assetVersion value to 1.5.0
      sed -i 's/"assetVersion": "[^"]*"/"assetVersion": "1.5.0"/' "$file"
      echo "Updated $file to version 1.5.0"
    else
      echo "No assetVersion field found in $file"
    fi
  else
    echo "WARNING: File $file not found"
  fi
done

echo "--- Step 7: Updating assetVersion in rate-limiting-policy.json ---"
if [ -f "configuration/rate-limiting-policy.json" ]; then
  # Update rate limiting policy to version 1.4.0 regardless of current version
  # First check if the file contains an assetVersion field
  if grep -q '"assetVersion"' "configuration/rate-limiting-policy.json"; then
    # Use sed to update the assetVersion value to 1.4.0
    sed -i 's/"assetVersion": "[^"]*"/"assetVersion": "1.4.0"/' "configuration/rate-limiting-policy.json"
    echo "Updated configuration/rate-limiting-policy.json to version 1.4.0"
  else
    echo "No assetVersion field found in configuration/rate-limiting-policy.json"
  fi
else
  echo "WARNING: configuration/rate-limiting-policy.json not found"
fi

# Ask the user how they want to review the changes
echo "--- Final Step: Review Changes ---"
echo "How would you like to review the changes?"
echo "1. Open in VS Code"
echo "2. Open Git Bash GUI"
echo "3. Show git status"
echo "4. Skip review"

while true; do
    read -p "Select an option (1-4): " choice
    case $choice in
        1)
            echo "Opening project in VS Code..."
            code .
            break
            ;;
        2)
            echo "Opening Git Bash GUI..."
            git gui &
            break
            ;;
        3)
            echo "Showing git status..."
            git status
            break
            ;;
        4)
            echo "Skipping review. You can review changes later with 'git status' or 'git diff'."
            break
            ;;
        *)
            echo "Invalid selection. Please enter a number between 1 and 4."
            ;;
    esac
done

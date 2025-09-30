#!/bin/bash

# Feature branch name for Mule Runtime upgrade
FEATURE_BRANCH="feature/MuleRuntimeUpgrade4.9"

#####################################################################################################
# This script automates the initial steps of a Mule Runtime upgrade.
# It should be run from the root of a project's directory.
# It creates a new feature branch for the upgrade.
#####################################################################################################

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repository. Please run this script from the root of a git repository."
    exit 1
fi

# Check if the feature branch already exists.
if git rev-parse --verify "$FEATURE_BRANCH" >/dev/null 2>&1; then
  # If the branch exists, check it out.
  echo "Branch $FEATURE_BRANCH already exists. Checking it out."
  git checkout "$FEATURE_BRANCH"
else
  # If the branch does not exist, create it from the current branch.
  echo "Branch $FEATURE_BRANCH does not exist. Creating it from current branch."
  git checkout -b "$FEATURE_BRANCH"
fi

############################################################################################################################
# These next lines updates the project runtime to Mule 4.9, java 17, and dependency versions to the latest stable versions.
############################################################################################################################

# Step 1: Update parent pom version
echo "--- Step 1: Updating parent pom version ---"
sed -i '/<parent>/,/<\/parent>/s|<version>.*</version>|<version>1.1.0</version>|' pom.xml

# Step 2: Update project artifact version
echo "--- Step 2: Updating this project artifact version ---"
sed -i '/<\/parent>/,/<properties>/s|<version>.*</version>|<version>1.1.0-SNAPSHOT</version>|' pom.xml

# Step 3: Update pom.xml properties
echo "--- Step 3: Updating runtime, munit, and maven.plugin properties ---"
sed -i 's|<munit.version>.*</munit.version>|<munit.version>3.5.0</munit.version>|' pom.xml
sed -i 's|<app.runtime>.*</app.runtime>|<app.runtime>4.9-java17</app.runtime>|' pom.xml
sed -i 's|<munit.app.runtime>.*</munit.app.runtime>|<munit.app.runtime>4.9.7</munit.app.runtime>|' pom.xml
sed -i 's|<mule.maven.plugin.version>.*</mule.maven.plugin.version>|<mule.maven.plugin.version>4.3.1</mule.maven.plugin.version>|' pom.xml

# Step 4: Update compiler target version in pom.xml
echo "--- Step 4: Updating compiler target version in pom.xml ---"
if grep -q "<compilerArgs>" pom.xml; then
    sed -i 's|<target>.*</target>|<target>17</target>|' pom.xml
fi

# Step 5: Update dependencies versions
echo "--- Step 5: Updating dependencies versions ---"

# Define the list of updated dependencies.
read -r -d '' updated_dependencies <<'EOF'
<dependencies>
    <dependency>
        <groupId>org.mule.tools.maven</groupId>
        <artifactId>mule-maven-plugin</artifactId>
        <version>${mule.maven.plugin.version}</version>
    </dependency>
    <dependency>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.13.0</version>
    </dependency>
    <dependency>
        <groupId>com.solacesystems</groupId>
        <artifactId>sol-jms</artifactId>
        <version>10.27.3</version>
    </dependency>
    <dependency>
			<groupId>com.solacesystems</groupId>
			<artifactId>sol-jms-ra</artifactId>
			<version>10.27.3</version>
	</dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-objectstore-connector</artifactId>
        <version>1.2.3</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-json-module</artifactId>
        <version>2.5.4</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-oauth-module</artifactId>
        <version>1.1.24</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-http-connector</artifactId>
        <version>1.10.5</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-apikit-module</artifactId>
        <version>1.11.7</version>
    </dependency>
    <dependency>
        <groupId>org.mule.module</groupId>
        <artifactId>mule-java-module</artifactId>
        <version>2.0.2</version>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-cloudhub-connector</artifactId>
        <version>1.2.0</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-sockets-connector</artifactId>
        <version>1.2.6</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-validation-module</artifactId>
        <version>2.0.7</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-jms-connector</artifactId>
        <version>1.10.2</version>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.modules</groupId>
        <artifactId>mule-secure-configuration-property-module</artifactId>
        <version>1.2.7</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-db-connector</artifactId>
        <version>1.14.16</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-sftp-connector</artifactId>
        <version>2.5.0</version>       
	</dependency>    
    <dependency>
        <groupId>net.sf.jt400</groupId>
        <artifactId>jt400</artifactId>
        <version>21.0.5</version>
    </dependency>
    <dependency>
        <groupId>org.mule.weave</groupId>
        <artifactId>assertions</artifactId>
        <version>2.10.0-20250729</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-spring-module</artifactId>
        <version>2.0.0</version>
    </dependency>
    <dependency>
        <groupId>com.mchange</groupId>
        <artifactId>c3p0</artifactId>
        <version>0.11.2</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-config</artifactId>
        <version>7.0.0-M1</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-ldap</artifactId>
        <version>7.0.0-M1</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-web</artifactId>
        <version>7.0.0-M1</version>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-salesforce-connector</artifactId>
        <version>11.2.2</version>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-salesforce-composite-connector</artifactId>
        <version>2.19.0</version>        
	</dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-file-connector</artifactId>
        <version>1.5.3</version>
    </dependency>
    <dependency>
        <groupId>com.solace.connector</groupId>
        <artifactId>solace-mulesoft-connector</artifactId>
        <version>1.8.0</version>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-ftps-connector</artifactId>
        <version>2.0.2</version>
    </dependency>
    <dependency>
			<groupId>org.mule.modules</groupId>
			<artifactId>mule-xml-module</artifactId>
			<version>1.4.2</version>
	</dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcprov-jdk18on</artifactId>
        <version>1.78.1</version>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bctls-jdk18on</artifactId>
        <version>1.78.1</version>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcpkix-jdk18on</artifactId>
        <version>1.78.1</version>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcutil-jdk18on</artifactId>
        <version>1.78.1</version>
    </dependency>
    <dependency>
        <groupId>com.microsoft.sqlserver</groupId>
        <artifactId>mssql-jdbc</artifactId>
        <version>11.2.0.jre17</version>
	</dependency>
    <dependency>
			<groupId>org.mule.connectors</groupId>
			<artifactId>mule-wsc-connector</artifactId>
			<version>1.11.3</version>			
	</dependency>
    <dependency>
        <groupId>org.apache.commons</groupId>
        <artifactId>commons-text</artifactId>
        <version>1.12.0</version>
    </dependency>
</dependencies>
EOF

# Extract all artifactIds from the dependencies section
pom_artifacts=$(sed -n '/<dependencies>/,/\/dependencies>/p' pom.xml | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p')

for artifactId in $pom_artifacts; do
    # Check if this artifact is in our update list
    if echo "$updated_dependencies" | grep -q "<artifactId>$artifactId</artifactId>"; then
        # Extract the new version from the update list
        new_version=$(echo "$updated_dependencies" | sed -n "/<artifactId>$artifactId<\/artifactId>/,/\/dependency>/p" | sed -n 's/.*<version>\(.*\)<\/version>.*/\1/p' | xargs)
        
        if [ -n "$new_version" ]; then
            echo "Updating $artifactId to version $new_version"
            # Update version only within the dependencies section to avoid plugin conflicts
            sed -i "/<dependencies>/,/<\/dependencies>/ { \#<artifactId>$artifactId</artifactId>#,/<\/dependency>/ s|<version>.*</version>|<version>$new_version</version>|; }" pom.xml
        fi
    else
        echo "       [x] '$artifactId' not in update list, may require manual update."
    fi
done


# Step 6: Update mule-artifact.json
echo "--- Step 6: Updating mule-artifact.json ---"
sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7"/g' mule-artifact.json
if ! grep -q '"javaSpecificationVersions"' mule-artifact.json; then
  sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7",\
	  "javaSpecificationVersions": ["17"]/' mule-artifact.json
fi

# Step 7: Update main-pipeline.yml
echo "--- Step 7: Updating main-pipeline.yml ---"
if [ -f "main-pipeline.yml" ]; then
    sed -i "s|ref:.*|ref: refs/tags/jdk17-maven3.8.6-1.1|" main-pipeline.yml
    sed -i "s|imagename:.*|imagename: localhost:5000/maven-mule-jdk17-maven3.8.6:1.0|" main-pipeline.yml
    sed -i "s|jdkVersion:.*|jdkVersion: '17'|" main-pipeline.yml
else
    echo "INFO: main-pipeline.yml not found. Please add the main-pipeline.yml file to the project."
fi

# Delete Jenkinsfile if it exists
echo "--- Step 8: Deleting Jenkinsfile ---"
if [ -f "Jenkinsfile" ]; then
    rm Jenkinsfile
else
    echo "INFO: Jenkinsfile not found, skipping deletion."
fi

# Step 9: Ask the user how they want to review the changes
echo "--- Step 9: Review Changes ---"
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

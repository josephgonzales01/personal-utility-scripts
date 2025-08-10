#!/bin/bash


###################################################################################
# These scripts clones a project from Azure DevOps, checks out the develop branch,
# and creates a new feature branch for a Mule Runtime upgrade.
#####################################################################################

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

############################################################################################################################
# These next lines updates the project runtime to Mule 4.9, java 17, and dependency versions to the latest stable versions.
############################################################################################################################

# Backup original files
echo "Backing up pom.xml ..."
cp pom.xml pom.xml.bak

# Step 1: Update parent pom version
echo "--- Step 1: Updating parent pom version ---"
sed -i '/<parent>/,/^<\/parent>/s|<version>.*</version>|<version>1.1.0</version>|' pom.xml

# Step 2: Update project artifact version
echo "--- Step 2: Updating this project artifact version ---"
sed -i '/<\/parent>/,/<properties>/s|<version>.*</version>|<version>1.1.0-SNAPSHOT</version>|' pom.xml

# Step 3: Update pom.xml properties
echo "--- Step 3: Updating runtime, munit, and maven.plugin properties ---"
sed -i 's|<munit.version>.*</munit.version>|<munit.version>3.4.0</munit.version>|' pom.xml
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

# Define the list of dependencies to update.
read -r -d '' dependencies_to_update <<'EOF'
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
        <version>2.5.3</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-oauth-module</artifactId>
        <version>1.1.24</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-http-connector</artifactId>
        <version>1.10.4</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-apikit-module</artifactId>
        <version>1.11.7</version>
    </dependency>
    <dependency>
        <groupId>org.mule.module</groupId>
        <artifactId>mule-java-module</artifactId>
        <version>2.0.1</version>
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
    <!--  https://mvnrepository.com/artifact/net.sf.jt400/jt400  -->
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
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-salesforce-connector</artifactId>
        <version>11.2.0</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-file-connector</artifactId>
        <version>1.5.3</version>
    </dependency>
    <dependency>
        <groupId>com.solace.connector</groupId>
        <artifactId>solace-mulesoft-connector</artifactId>
        <version>1.7.0</version>
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
</dependencies>
EOF

# Part 1 & 2 combined: Process all dependencies from pom.xml
echo "--- Step 5a: Processing dependencies from pom.xml ---"
# Extract the dependencies block to avoid parsing the whole file repeatedly
pom_dependencies=$(sed -n '/<dependencies>/,/\/dependencies>/p' pom.xml)

# Get all artifactIds from the pom's dependencies block
all_pom_artifacts=$(echo "$pom_dependencies" | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p')

for artifactId in $all_pom_artifacts; do
    # Check if the artifact is in our update list
    if echo "$dependencies_to_update" | grep -q "<artifactId>$artifactId</artifactId>"; then
        # It's in the list, so let's update it.
        # Extract the new version from our list.
        new_version=$(echo "$dependencies_to_update" | sed -n "/<artifactId>$artifactId<\/artifactId>/,/\/dependency>/p" | sed -n 's/.*<version>\(.*\)<\/version>.*/\1/p' | xargs)

        if [ -n "$new_version" ]; then
            echo "Updating $artifactId to version $new_version"
            # Use a precise sed command to update the version within the dependencies block
            # Using '#' as a delimiter to avoid escaping slashes in tags.
            sed -i "\#<dependencies>#,\#</dependencies># { \#<artifactId>$artifactId</artifactId>#,\#</dependency># s|<version>.*</version>|<version>$new_version</version>|; }" pom.xml
        fi
    else
        # It's not in the list, so warn the user.
        echo "INFO: Dependency '$artifactId' in pom.xml is not in the automatic update list and may require manual update."
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
    echo "[X] Step 7: main-pipeline.yml updated."
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

# Step 8: Ask the user if they want to open the project in VS Code.
echo "--- Step 9: Open VSCode ---"
read -p "Do you want to open the project in VSCode? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  code .
fi

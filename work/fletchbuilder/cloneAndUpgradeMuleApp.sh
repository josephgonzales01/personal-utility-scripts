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
echo "[X] Step 1: Parent pom version updated."

# Step 2: Update project artifact version
echo "--- Step 2: Updating project artifact version ---"
sed -i '/<\/parent>/,/<properties>/s|<version>.*</version>|<version>1.1.0-SNAPSHOT</version>|' pom.xml
echo "[X] Step 2: Project artifact version updated."

# Step 3: Update pom.xml properties
echo "--- Step 3: Updating pom.xml properties ---"
sed -i 's|<munit.version>.*</munit.version>|<munit.version>3.4.0</munit.version>|' pom.xml
sed -i 's|<app.runtime>.*</app.runtime>|<app.runtime>4.9-java17</app.runtime>|' pom.xml
sed -i 's|<munit.app.runtime>.*</munit.app.runtime>|<munit.app.runtime>4.9.7</munit.app.runtime>|' pom.xml
sed -i 's|<mule.maven.plugin.version>.*</mule.maven.plugin.version>|<mule.maven.plugin.version>4.3.1</mule.maven.plugin.version>|' pom.xml
echo "[X] Step 3: pom.xml properties updated."

# Step 4: Update compiler target version in pom.xml
echo "--- Step 4: Updating compiler target version in pom.xml ---"
if grep -q "<compilerArgs>" pom.xml; then
    sed -i 's|<target>.*</target>|<target>17</target>|' pom.xml
fi
echo "[X] Step 4: Compiler target version updated."

# Step 5: Update dependencies versions
echo "--- Step 5: Updating dependencies versions ---"
echo ">> This step will only update dependencies explicitly listed. All other dependencies will be flagged for manual review."

# Define the list of dependencies to update.
read -r -d '' dependencies_to_update <<'EOF'
<dependencies>
    <dependency>
        <groupId>com.solacesystems</groupId>
        <artifactId>sol-jms</artifactId>
        <version>${solace.jms.version}</version>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-objectstore-connector</artifactId>
        <version>1.2.3</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-json-module</artifactId>
        <version>2.5.3</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-oauth-module</artifactId>
        <version>1.1.24</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-http-connector</artifactId>
        <version>1.10.4</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-apikit-module</artifactId>
        <version>1.11.7</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.module</groupId>
        <artifactId>mule-java-module</artifactId>
        <version>2.0.1</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-cloudhub-connector</artifactId>
        <version>1.2.0</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-sockets-connector</artifactId>
        <version>1.2.6</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-validation-module</artifactId>
        <version>2.0.7</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-jms-connector</artifactId>
        <version>1.10.2</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.modules</groupId>
        <artifactId>mule-secure-configuration-property-module</artifactId>
        <version>1.2.7</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-db-connector</artifactId>
        <version>1.14.16</version>
        <classifier>mule-plugin</classifier>
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
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-spring-module</artifactId>
        <version>2.0.0</version>
        <classifier>mule-plugin</classifier>
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
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.mule.connectors</groupId>
        <artifactId>mule-file-connector</artifactId>
        <version>1.5.3</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>com.solace.connector</groupId>
        <artifactId>solace-mulesoft-connector</artifactId>
        <version>1.7.0</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-ftps-connector</artifactId>
        <version>2.0.2</version>
        <classifier>mule-plugin</classifier>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcprov-jdk18on</artifactId>
        <version>1.78.1</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bctls-jdk18on</artifactId>
        <version>1.78.1</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcpkix-jdk18on</artifactId>
        <version>1.78.1</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcutil-jdk18on</artifactId>
        <version>1.78.1</version>
        <scope>runtime</scope>
    </dependency>
</dependencies>
EOF

# Part 1: Update dependencies that are found in the list
echo "--- Updating managed dependencies in pom.xml ---"
managed_artifacts=$(echo "$dependencies_to_update" | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p')

# Process each dependency in the list
while IFS= read -r line; do
    if [[ $line == *"<artifactId>"* ]]; then
        artifactId=$(echo "$line" | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p' | xargs)
    fi
    if [[ $line == *"<version>"* ]]; then
        version=$(echo "$line" | sed -n 's/.*<version>\(.*\)<\/version>.*/\1/p' | xargs)
        if [ -n "$artifactId" ] && [ -n "$version" ]; then
            # Check if this dependency exists in pom.xml's dependencies block before attempting to update
            if sed -n '/<dependencies>/,/\/dependencies>/p' pom.xml | grep -q "<artifactId>$artifactId</artifactId>";
 then
                echo "Updating $artifactId to version $version"
                # Use a more precise sed command to update the version within a dependency block
                sed -i "/<artifactId>$artifactId<\/artifactId>/, /<\/dependency>/ s|<version>.*<\/version>|<version>$version<\/version>|" pom.xml
            else
                echo "INFO: Dependency '$artifactId' not found in pom.xml, skipping update"
            fi
            artifactId=""
            version=""
        fi
    fi
done <<< "$dependencies_to_update"

# Part 2: Identify dependencies in pom.xml that are not in the list
echo "--- Checking for unmanaged dependencies in pom.xml ---"
all_pom_artifacts=$(sed -n '/<dependencies>/,/\/dependencies>/p' pom.xml | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p')

for artifactId in $all_pom_artifacts; do
    if ! echo "$managed_artifacts" | grep -q "^$artifactId$"; then
        echo "INFO: Dependency '$artifactId' in pom.xml is not in the automatic update list and may require manual update."
    fi
done

echo "[X] Step 5: Dependencies versions updated and checked."


# Step 6: Update mule-artifact.json
echo "--- Step 6: Updating mule-artifact.json ---"
sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7"/g' mule-artifact.json
if ! grep -q '"javaSpecificationVersions"' mule-artifact.json; then
  sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7",\n	  "javaSpecificationVersions": ["17"]/' mule-artifact.json
fi
echo "[X] Step 6: mule-artifact.json updated."

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

# Step 8: Ask the user if they want to open the project in VS Code.
echo "--- Step 8: Open VSCode ---"
read -p "Do you want to open the project in VSCode? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  code .
fi

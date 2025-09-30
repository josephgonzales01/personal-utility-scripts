#!/bin/bash

#####################################################################################################
# This script automates the initial steps of a Mule Runtime upgrade.
# It should be run from the root of a project's directory.
#####################################################################################################

############################################################################################################################
# These next lines updates the project runtime to Mule 4.9, java 17, and dependency versions to the latest stable versions.
############################################################################################################################

# Check if a project name is provided.
if [ -n "$1" ]; then
  # If a project name is provided, check if it's a valid directory.
  if [ -d "$1" ]; then
    echo "Changing to directory '$1'..."
    cd "$1"
  else
    # If the directory doesn't exist, exit the script.
    echo "Error: Directory '$1' not found."
    exit 1
  fi
else
  # If no project name is provided, run in the current directory.
  echo "No project name provided. Running in the current directory."
fi

# Check if pom.xml exists before proceeding.
if [ ! -f "pom.xml" ]; then
    echo "Error: pom.xml not found in this directory. Exiting."
    exit 1
fi

# Step 1: Update pom.xml properties
echo "--- Step 1: Updating runtime, munit, and maven.plugin properties ---"
sed -i 's|<munit.version>.*</munit.version>|<munit.version>3.5.0</munit.version>|' pom.xml
sed -i 's|<app.runtime>.*</app.runtime>|<app.runtime>4.9.9</app.runtime>|' pom.xml
sed -i 's|<munit.app.runtime>.*</munit.app.runtime>|<munit.app.runtime>4.9.7</munit.app.runtime>|' pom.xml
sed -i 's|<mule.maven.plugin.version>.*</mule.maven.plugin.version>|<mule.maven.plugin.version>4.3.1</mule.maven.plugin.version>|' pom.xml

# Step 2: Update compiler target version in pom.xml
echo "--- Step 2: Updating compiler target version in pom.xml ---"
if grep -q "<compilerArgs>" pom.xml; then
    sed -i 's|<target>.*</target>|<target>17</target>|' pom.xml
fi

# Step 3: Update dependencies versions
echo "--- Step 3: Updating dependencies versions ---"

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
        <version>1.2.4</version>
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
        <version>1.2.7</version>
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-validation-module</artifactId>
        <version>2.0.8</version>
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
        <version>1.5.4</version>
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
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-scripting-module</artifactId>
        <version>2.1.1</version>        
	</dependency>
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>mule-mongodb-connector</artifactId>
        <version>6.3.9</version>        
    </dependency>
    <dependency>
        <groupId>org.mongodb</groupId>
        <artifactId>mongodb-driver-legacy</artifactId>
        <version>5.5.0</version>
    </dependency> 
    <dependency>
        <groupId>com.mulesoft.connectors</groupId>
        <artifactId>anypoint-mq-connector</artifactId>
        <version>4.0.13</version>       
    </dependency>
    <dependency>
        <groupId>org.mule.modules</groupId>
        <artifactId>mule-tracing-module</artifactId>
        <version>1.2.0</version>        
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


# Step 4: Update mule-artifact.json
echo "--- Step 4: Updating mule-artifact.json ---"
sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.9"/g' mule-artifact.json
if ! grep -q '"javaSpecificationVersions"' mule-artifact.json; then
  sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.9",\
	  "javaSpecificationVersions": ["17"]/' mule-artifact.json
fi

# Step 7: Review changes in VS Code
echo ""
echo "----------------------------------------"
echo "Updates complete."
read -p "Would you like to open the project in VS Code to review the changes? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Opening project in VS Code..."
    code .
fi

#!/bin/bash

# This script updates the project files according to UpgradeMuleApp.md

# Backup original files
echo "Backing up pom.xml, mule-artifact.json, and main-pipeline.yml..."
cp pom.xml pom.xml.bak
cp mule-artifact.json mule-artifact.json.bak
cp main-pipeline.yml main-pipeline.yml.bak

# Step 1: Update pom.xml properties
echo "--- Step 1: Updating pom.xml properties ---"
sed -i 's|<munit.version>.*</munit.version>|<munit.version>3.4.0</munit.version>|' pom.xml
sed -i 's|<app.runtime>.*</app.runtime>|<app.runtime>4.9-java17</app.runtime>|' pom.xml
sed -i 's|<munit.app.runtime>.*</munit.app.runtime>|<munit.app.runtime>4.9.7</munit.app.runtime>|' pom.xml
sed -i 's|<mule.maven.plugin.version>.*</mule.maven.plugin.version>|<mule.maven.plugin.version>4.3.1</mule.maven.plugin.version>|' pom.xml
echo "[X] Step 1: pom.xml properties updated."

# Step 2: Update parent pom version
echo "--- Step 2: Updating parent pom version ---"
sed -i '/<parent>/,/^<\/parent>/s|<version>.*</version>|<version>1.1.0</version>|' pom.xml
echo "[X] Step 2: Parent pom version updated."

# Step 3: Update project artifact version
echo "--- Step 3: Updating project artifact version ---"
sed -i '12s|<version>.*</version>|<version>1.1.0-SNAPSHOT</version>|' pom.xml
echo "[X] Step 3: Project artifact version updated."

# Step 4: Update dependencies versions
echo "--- Step 4: Updating dependencies versions ---"

# Read dependencies from the here-document
while IFS= read -r line; do
    if [[ $line == *"<artifactId>"* ]]; then
        artifactId=$(echo "$line" | sed -n 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p')
    fi
    if [[ $line == *"<version>"* ]]; then
        version=$(echo "$line" | sed -n 's/.*<version>\(.*\)<\/version>.*/\1/p')
        if [ -n "$artifactId" ] && [ -n "$version" ]; then
            echo "Updating $artifactId to version $version"
            # Use a more specific sed command to avoid issues with nested dependencies
            sed -i "/<artifactId>$artifactId<\/artifactId>/{N;s|<version>.*<\/version>|<version>$version<\/version>|}" pom.xml
            artifactId=""
            version=""
        fi
    fi
done <<'EOF'
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
        <version>1.11.6</version>
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
echo "[X] Step 4: Dependencies versions updated."


# Step 5: Update mule-artifact.json
echo "--- Step 5: Updating mule-artifact.json ---"
sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7"/g' mule-artifact.json
if ! grep -q '"javaSpecificationVersions"' mule-artifact.json; then
  sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7",\n	  "javaSpecificationVersions": ["17"]/' mule-artifact.json
fi
echo "[X] Step 5: mule-artifact.json updated."

# Step 6: Update main-pipeline.yml
echo "--- Step 6: Updating main-pipeline.yml ---"
sed -i "s|ref:.*|ref: refs/tags/jdk17-maven3.8.6-1.1|" main-pipeline.yml
sed -i "s|imagename:.*|imagename: localhost:5000/maven-mule-jdk17-maven3.8.6:1.0|" main-pipeline.yml
sed -i "s|jdkVersion:.*|jdkVersion: '17'|" main-pipeline.yml
echo "[X] Step 6: main-pipeline.yml updated."

# Step 7: Update compiler target version in pom.xml
echo "--- Step 7: Updating compiler target version in pom.xml ---"
if grep -q "<compilerArgs>" pom.xml; then
    sed -i 's|<target>.*</target>|<target>17</target>|' pom.xml
fi
echo "[X] Step 7: Compiler target version updated."


echo -e "\nUpgrade script finished."

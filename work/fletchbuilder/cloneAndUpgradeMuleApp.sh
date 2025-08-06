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
sed -i '/<parent>/,/<\/parent>/s|<version>.*</version>|<version>1.1.0</version>|' pom.xml
echo "[X] Step 2: Parent pom version updated."

# Step 3: Update project artifact version
echo "--- Step 3: Updating project artifact version ---"
sed -i '12s|<version>.*</version>|<version>1.1.0-SNAPSHOT</version>|' pom.xml
echo "[X] Step 3: Project artifact version updated."

# Step 4: Update mule-artifact.json
echo "--- Step 4: Updating mule-artifact.json ---"
sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7"/g' mule-artifact.json
if ! grep -q '"javaSpecificationVersions"' mule-artifact.json; then
  sed -i 's/"minMuleVersion": ".*"/"minMuleVersion": "4.9.7",\n  "  javaSpecificationVersions": ["17"]/' mule-artifact.json
fi
echo "[X] Step 4: mule-artifact.json updated."

# Step 5: Update main-pipeline.yml
echo "--- Step 5: Updating main-pipeline.yml ---"
sed -i "s|ref:.*|ref: refs/tags/jdk17-maven3.8.6-1.1|" main-pipeline.yml
sed -i "s|imagename:.*|imagename: localhost:5000/maven-mule-jdk17-maven3.8.6:1.0|" main-pipeline.yml
sed -i "s|jdkVersion:.*|jdkVersion: '17'|" main-pipeline.yml
echo "[X] Step 5: main-pipeline.yml updated."

# Step 6: Update compiler target version in pom.xml
echo "--- Step 6: Updating compiler target version in pom.xml ---"
if grep -q "<compilerArgs>" pom.xml; then
    sed -i 's|<target>.*</target>|<target>17</target>|' pom.xml
fi
echo "[X] Step 6: Compiler target version updated."


echo -e "\nUpgrade script finished."

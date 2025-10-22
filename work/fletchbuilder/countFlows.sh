#!/bin/bash

# Find all XML files in the src/main/mule directory
files=$(find src/main/mule -name "*.xml")

total_flow_count=0
total_sub_flow_count=0

echo "----------------------------------------"
echo "Flow and Sub-flow count per file"
echo "----------------------------------------"

for file in $files
do
  # Count occurrences of "<flow name"
  flows=$(grep -c "<flow name" "$file")
  total_flow_count=$((total_flow_count + flows))

  # Count occurrences of "<sub-flow name"
  sub_flows=$(grep -c "<sub-flow name" "$file")
  total_sub_flow_count=$((total_sub_flow_count + sub_flows))

  echo "$file: flow=$flows sub-flow=$sub_flows"
done

echo "----------------------------------------"
echo "Total flows: $total_flow_count"
echo "Total sub-flows: $total_sub_flow_count"
echo "Total: $((total_flow_count + total_sub_flow_count))"

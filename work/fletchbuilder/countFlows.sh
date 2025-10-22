#!/bin/bash

# Find all XML files in the src/main/mule directory
files=$(find src/main/mule -name "*.xml")

flow_count=0
sub_flow_count=0

for file in $files
do
  # Count occurrences of "<flow name"
  flows=$(grep -c "<flow name" "$file")
  flow_count=$((flow_count + flows))

  # Count occurrences of "<sub-flow name"
  sub_flows=$(grep -c "<sub-flow name" "$file")
  sub_flow_count=$((sub_flow_count + sub_flows))
done

echo "Number of flows: $flow_count"
echo "Number of sub-flows: $sub_flow_count"
echo "Total: $((flow_count + sub_flow_count))"

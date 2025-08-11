#!/bin/bash

# fixExtraBracket.sh
# Script to fix extra closing brackets in logger message attributes in *-common.xml files

echo "=== Fix Extra Bracket Script ==="
echo "Scanning for *-common.xml files and fixing extra closing brackets in logger message attributes..."
echo

# Function to count brackets in a string
count_brackets() {
    local text="$1"
    local open_count=$(echo "$text" | grep -o '\[' | wc -l)
    local close_count=$(echo "$text" | grep -o '\]' | wc -l)
    echo "$open_count $close_count"
}

# Function to fix extra closing brackets
fix_extra_brackets() {
    local message="$1"
    local open_count close_count
    read open_count close_count <<< $(count_brackets "$message")
    
    # If there are more closing brackets than opening brackets
    if [ $close_count -gt $open_count ]; then
        local extra_brackets=$((close_count - open_count))
        
        # Remove extra closing brackets from the end
        local fixed_message="$message"
        for ((i=1; i<=extra_brackets; i++)); do
            # Remove the last occurrence of ]
            fixed_message=$(echo "$fixed_message" | sed 's/\(.*\)\]/\1/')
        done
        
        echo "$fixed_message"
        return 0
    else
        echo "$message"
        return 1
    fi
}

# Find all *-common.xml files
files_found=0
files_processed=0
total_fixes=0

echo "Searching for *-common.xml files..."

# Use find to locate all *-common.xml files recursively
for file in $(find . -name "*-common.xml" -type f); do
    files_found=$((files_found + 1))
    echo
    echo "Processing file: $file"
    
    # Check if file exists and is readable
    if [[ ! -r "$file" ]]; then
        echo "Error: Cannot read file $file"
        continue
    fi
    
    # Create a backup
    cp "$file" "${file}.backup"
    
    file_modified=false
    fixes_in_file=0
    
    # Process each logger line that has extra brackets
    while IFS= read -r line; do
        # Check if line contains a logger element with message attribute
        if echo "$line" | grep -q '<logger.*message=".*"'; then
            # Extract the message attribute value
            message_attr=$(echo "$line" | sed -n 's/.*message="\([^"]*\)".*/\1/p')
            
            if [[ -n "$message_attr" ]]; then
                # Try to fix extra brackets
                fixed_message=$(fix_extra_brackets "$message_attr")
                fix_result=$?
                
                if [[ $fix_result -eq 0 ]]; then
                    echo "  Found logger with extra brackets:"
                    echo "    Original: $message_attr"
                    echo "    Fixed:    $fixed_message"
                    
                    # Escape special characters for sed
                    escaped_original=$(echo "$message_attr" | sed 's/[[\.*^$()+?{|]/\\&/g')
                    escaped_fixed=$(echo "$fixed_message" | sed 's/[[\.*^$()+?{|]/\\&/g')
                    
                    # Replace only the message content in the file
                    sed -i "s/message=\"${escaped_original}\"/message=\"${escaped_fixed}\"/g" "$file"
                    
                    file_modified=true
                    fixes_in_file=$((fixes_in_file + 1))
                    total_fixes=$((total_fixes + 1))
                fi
            fi
        fi
    done < "${file}.backup"
    
    # Report results
    if [[ "$file_modified" == true ]]; then
        echo "  ✓ File updated with $fixes_in_file fix(es)"
        echo "  ✓ Backup saved as ${file}.backup"
        files_processed=$((files_processed + 1))
    else
        rm "${file}.backup"
        echo "  ✓ No fixes needed"
    fi
    
done

# Summary
echo
echo "=== Summary ==="
echo "Files found: $files_found"
echo "Files processed: $files_processed"
echo "Total fixes applied: $total_fixes"

if [[ $total_fixes -gt 0 ]]; then
    echo
    echo "✓ Script completed successfully with $total_fixes fix(es) applied!"
    echo "✓ Backup files created with .backup extension"
else
    echo
    echo "✓ Script completed - no fixes were needed!"
fi

echo
echo "Note: Please review the changes and test your application before committing."

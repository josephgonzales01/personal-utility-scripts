#!/bin/bash

# fixExtraBracket.sh
# Script to fix extra closing brackets in logger message attributes in *-common.xml files

# Check if a project name is provided as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name>"
  echo "Note: This script should be run from the parent directory of the project"
  exit 1
fi

# Set the project name from the first argument.
PROJECT_NAME=$1

echo "=== Fix Extra Bracket Script ==="
echo "Project: $PROJECT_NAME"
echo "Scanning for *-common.xml files and fixing extra closing brackets in logger message attributes..."
echo


# Change into the project directory
if [ ! -d "$PROJECT_NAME" ]; then
    echo "Error: Project directory '$PROJECT_NAME' not found"
    exit 1
fi

echo "Changing to project directory: $PROJECT_NAME"
cd "$PROJECT_NAME"

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
    cp "$file" "${file}.bak"
    
    file_modified=false
    fixes_in_file=0
    
    # Read the entire file content and process it with awk to handle multi-line logger elements
    awk '
    BEGIN {
        in_logger = 0
        logger_content = ""
        line_start = 0
        fixes = 0
    }
    
    # Function to count brackets
    function count_brackets(text) {
        open_count = gsub(/\[/, "[", text)
        close_count = gsub(/\]/, "]", text)
        return open_count " " close_count
    }
    
    # Function to fix extra brackets
    function fix_extra_brackets(message) {
        bracket_counts = count_brackets(message)
        split(bracket_counts, counts, " ")
        open_count = counts[1]
        close_count = counts[2]
        
        if (close_count > open_count) {
            extra_brackets = close_count - open_count
            fixed_message = message
            
            # Remove extra closing brackets from the end
            for (i = 1; i <= extra_brackets; i++) {
                sub(/\]$/, "", fixed_message)
            }
            
            return fixed_message
        }
        return message
    }
    
    /<logger/ {
        in_logger = 1
        logger_content = $0
        line_start = NR
        
        # Check if logger element is complete on this line
        if (/>/) {
            in_logger = 0
            # Process single-line logger
            if (match(logger_content, /message="([^"]*)"/, arr)) {
                original_message = arr[1]
                fixed_message = fix_extra_brackets(original_message)
                
                if (original_message != fixed_message) {
                    print "  Found logger with extra brackets on line " line_start ":" > "/dev/stderr"
                    print "    Original: " original_message > "/dev/stderr"
                    print "    Fixed:    " fixed_message > "/dev/stderr"
                    
                    # Replace the message in the logger content
                    gsub(/message="[^"]*"/, "message=\"" fixed_message "\"", logger_content)
                    fixes++
                }
            }
            print logger_content
        }
        next
    }
    
    in_logger && />/ {
        # End of multi-line logger element
        logger_content = logger_content "\n" $0
        in_logger = 0
        
        # Process multi-line logger
        if (match(logger_content, /message="([^"]*)"/, arr)) {
            original_message = arr[1]
            fixed_message = fix_extra_brackets(original_message)
            
            if (original_message != fixed_message) {
                print "  Found logger with extra brackets starting at line " line_start ":" > "/dev/stderr"
                print "    Original: " original_message > "/dev/stderr"
                print "    Fixed:    " fixed_message > "/dev/stderr"
                
                # Replace the message in the logger content
                gsub(/message="[^"]*"/, "message=\"" fixed_message "\"", logger_content)
                fixes++
            }
        }
        print logger_content
        next
    }
    
    in_logger {
        # Continue building multi-line logger element
        logger_content = logger_content "\n" $0
        next
    }
    
    !in_logger {
        # Regular line, just print it
        print $0
    }
    
    END {
        print fixes > "/tmp/awk_fixes_count"
    }
    ' "${file}.bak" > "$file"
    
    # Get the number of fixes from awk
    if [[ -f "/tmp/awk_fixes_count" ]]; then
        fixes_in_file=$(cat /tmp/awk_fixes_count)
        rm -f /tmp/awk_fixes_count
    else
        fixes_in_file=0
    fi
    
    # Report results
    if [[ $fixes_in_file -gt 0 ]]; then
        echo "  ✓ File updated with $fixes_in_file fix(es)"
        echo "  ✓ Backup saved as ${file}.bak"
        files_processed=$((files_processed + 1))
        total_fixes=$((total_fixes + fixes_in_file))
        file_modified=true
    else       
        echo "  ✓ No fixes needed"
    fi
    
    # Remove backup file
    rm "${file}.bak"
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
else
    echo
    echo "✓ Script completed - no fixes were needed!"
fi

echo
echo "Note: Please review the changes and test your application before committing."

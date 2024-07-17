#!/bin/bash

# Default values for parameters
count=2
name="student"
input_file_path="./scripts/vm-windows-template"

# Function to replace variables in the file
update_file() {
  local input_file="$1"
  local student_number="$2"
  local name="$3"
  local output_file="$4"
  
  # Initialize an associative array to store the variable replacements
  declare -A variables_to_update

  # Read through the file line by line
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Check for 'resource' or 'data' line and capture the second quoted string
    if [[ "$line" =~ ^(resource|data)\ \"[^\"]+\"\ \"([^\"]+)\" ]]; then
      resource_type="${BASH_REMATCH[1]}"
      second_quoted_variable="${BASH_REMATCH[2]}"
      
      # Create the new variable name and store it in the associative array
      new_variable_name="${second_quoted_variable}${student_number}"
      variables_to_update["$second_quoted_variable"]="$new_variable_name"
      
      # Replace the second quoted variable with the updated name in the line
      line=$(echo "$line" | sed "s/\(${resource_type} \"[^\"]*\" \"\)[^\"]*/\1${new_variable_name}/")
    fi

    # Add the modified line to the output
    echo "$line"
  done < "$input_file" > "$output_file.tmp"

  # Perform replacements for all stored variables
  while IFS= read -r line || [[ -n "$line" ]]; do
    for key in "${!variables_to_update[@]}"; do
      line=$(echo "$line" | sed "s/\b$key\b/${variables_to_update[$key]}/g")
    done

    # Replace 'windows_hostname' with the updated name
    line=$(echo "$line" | sed "s/student}/${name}${student_number}}/g")

    # Write the final modified line to the output file
    echo "$line"
  done < "$output_file.tmp" > "$output_file"

  # Clean up temporary file
  rm "$output_file.tmp"
}

# Parse command-line arguments
while getopts "c:n:" opt; do
  case $opt in
    c) count=$OPTARG ;;
    n) name=$OPTARG ;;
    *) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check if count is provided and valid
if [ -z "$count" ] || ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -le 0 ]; then
  echo "Error: Please specify a valid number of students using the -c option."
  exit 1
fi

# Iterate over the number of students
for (( i=1; i<=count; i++ )); do
  student_number=$i
  output_file="vm-windows-${name}${student_number}.tf"
  
  # Update the file for the current student
  update_file "$input_file_path" "$student_number" "$name" "$output_file"

  echo "Successfully created file: $output_file"
done


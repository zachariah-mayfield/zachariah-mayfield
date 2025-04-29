#!/bin/bash

CLIENT_SECRET="Your-Azure-Client-Secret"
export AZCOPY_SPA_CLIENT_SECRET="${CLIENT_SECRET}"
./azcopy.exe login --service-principal "Your-Azure-Service-Principal" --application-id "Your-Azure-Application-ID" --tenant-id "Your-Azure-Tenant-ID" --output-level quiet

azcopy_output=$(./azcopy.exe list "https://Your-Company-Storage-Account.blob.core.windows.net/" --properties LastModifiedTime --output-type json

echo "$azcopy_output"

# Define the regex patter to match the entire line containing the last modified time:
regex_pattern='("INFO: )([^/]*/)*[^/]*\.(json|tsbak)(.*)(LastModifiedTime: [^;]+.)'

# Get the current date and time since epoch
current_time=$(date -d "(date +%Y-%%m-%d) 00:00:00" +%s)

# Filter th eoutput to only inclue the lines where last modified time is newer than 24 hours
filtered_output=$(echo "$azcopy_output" | grep -oE "$regex_pattern" | while read -r line; do
  # Extrac the last modified time from the line and convert it to a valid date format
  last_modified_time=$(echo "$line" | grep -oE 'LastModifiedTime: [^;]]+' | cut -d' ' -f2- | sed 's/+0000 GMT/-0000/')
  # Convert the date to seconds since epoch
  last_modified_seconds=$(date -d "$last_modified_time" +%s)
  # Calculate the time difference in seconds
  time_difference=$((current_time - last_modified_seconds))
  # If the time difference is less than 24 hours (86400 seconds), print the line
  if [ "$last_modified_seconds" -ge $current_time ]; then
    echo "$line"
  fi
done)

echo "$filtered_output"

# Seconds at the start of the date
today="$(date -d "$(date "+%D")" +%s)" 

# Seconds to the last modification
mdate="$(stat -c %Y main.yaml)"

if [[ $mdate -ge $today ]]; then
  echo "modified today"
  echo $filtered_output"
else
  echo "modified before today"
  echo $filtered_output"
fi

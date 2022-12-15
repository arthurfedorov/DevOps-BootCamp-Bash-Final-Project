#!/bin/bash

# Current script version
currentVersion="1.23.0"

# Function that print help information about the script
Help() {
  echo "Description: Bash tool to transfer files from the command line."
  echo "Usage: "
  echo "-d Download single file from the transfer.sh to the specified directory"
  echo "-h  Show the help"
  echo "-v  Get the tool version"
  echo "Examples: "
  echo "  ./transfer.sh test.txt test2.txt -- Upload files"
  echo "  ./transfer.sh -d ./test Mij6ca test.txt -- Download file"
}

# Set a flag when processing the arguments to use upload function by default
direction=up

# Using while loop to work with flags
while getopts ":d:hv" flag; do
  case "${flag}" in
    h)
      Help
      exit 0
      ;;
    v)
      echo $currentVersion
      exit 0
      ;;
    d)
      # if run with flag -d, download function will run
      direction=down
      ;;
    *) echo "Invalid option"
       echo "try transfer -h' more information"
       exit 1
       ;;
  esac
done

# Function for uploading a file to transfer
singleUpload() {
  local filepath=$1
  local transfer_path=$2
  local url

  # upload the file using curl
  url=$(curl --progress-bar --upload-file "$filepath" "https://transfer.sh/$transfer_path")

  # return the URL of the uploaded file
  echo "$url"
}

# Function for printing the response from uploading a file filepath: the path
# to the file that was uploaded
printUploadResponse() {
  local filepath=$1
  local url

  # print a message indicating that the file is being uploaded
  echo "Uploading $filepath"

  # upload the file and get the URL of the uploaded file
  url=$(singleUpload "$filepath")

  # print the URL of the uploaded file
  echo "Transfer File URL: $url"
}

# Function for downloading file from transfer.sh
singleDownload() {
  local destination=$1
  local url=$2
  local file_name=$3

  curl -# "https://transfer.sh/$url/$file_name" -o "$destination/$file_name"

  return $?
}

# Function for printing the response from downloading a file url: the URL
# of the file to download
printDownloadResponse() {
  local exit_code=$?
  if [ "$exit_code" -eq 0 ]; then
    echo "Success!"
  else
    echo "Error: There was a problem downloading the file."
  fi
}

# Main function to run script
function main() {
  # Check if at least one file was specified
  if [ "$#" -eq 0 ]; then
    echo "Error: no files specified"
  fi

  # upload each file and print the response
  for file in "$@"; do
    printUploadResponse "$file"
  done
}

# This condition allows to run singleDownload() or main() which run a
# singleUpload() functions
if [[ $direction == up ]]; then
  main "$@"
else
  singleDownload "$2" "$3" "$4"
  printDownloadResponse
fi

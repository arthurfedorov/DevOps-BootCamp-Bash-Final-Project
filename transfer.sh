#!/bin/bash

currentVersion="0.0.1"

# Check for the -h flag and output the help message if it is present
while getopts "hvd" flag; do
  case "${flag}" in
    h)
      cat <<EOF
Description: Bash tool to transfer files from the command line.
Usage:
  -d  Download single file from the transfer.sh to the specified directory
  -h  Show the help
  -v  Get the tool version
Examples:
  ./transfer.sh test.txt test2.txt  Upload files test.txt test2.txt
  ./transfer.sh -d ./test Mij6ca test.txt
EOF
      exit 0
      ;;
    v)
      echo $currentVersion
      exit 0
      ;;
    d)
      ;;
    *) echo "./transfer: try './transfer -h' more information"
       exit 1
       ;;
  esac
done

# function for uploading a file to transfer.sh
# filepath: the path to the file to be uploaded
# returns the URL of the uploaded file
function singleUpload() {
  local filepath=$1
  local url
#  local transfer_path=$2

  # upload the file using curl
  url=$(curl --progress-bar --upload-file "$filepath" "https://transfer.sh/$filepath")

  # return the URL of the uploaded file
  echo "$url"
}

# function for printing the response from uploading a file
# filepath: the path to the file that was uploaded
function printUploadResponse() {
  local filepath=$1
  local url

  # print a message indicating that the file is being uploaded
  echo "Uploading $filepath"

  # upload the file and get the URL of the uploaded file
  url=$(singleUpload "$filepath")

  # print the URL of the uploaded file
  echo "Transfer File URL: $url"
}

function singleDownload() {
  local url=$1
  local dest=$2

  # download the file using curl
  curl -L -# "$url" -o "$dest/$(basename "$url")"
}

# function for printing the response from downloading a file
# url: the URL of the file to download
function printDownloadResponse() {
  local url=$1

  # print a message indicating that the file is being downloaded
  echo "Downloading $(basename "$url")"

  # download the file
  singleDownload "$url" "$dest"

  # print a success message
  echo "Success!"
}

# main function
function main() {
  # check if at least one file was specified
  if [ $# -eq 0 ]; then
    echo "Error: no files specified"
    exit 1
  fi

  # upload each file and print the response
  for file in "$@"; do
    printUploadResponse "$file"
  done
}

# call the main function
main "$@"
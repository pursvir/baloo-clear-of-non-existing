#!/usr/bin/env bash

declare -a file_types=(
  "Archive"
  "Audio"
  "Video"
  "Folder"
  "Document"
  "Media"
  "Image"
  "Text"
)

contains_newline_chars=0
for file_type in "${file_types[@]}"; do
  baloosearch6 "type:$file_type" | head -n -1 | while read -r filename; do
    if [[ -z "$filename" && contains_newline_chars -eq 0 ]]; then
      continue
    fi
    if [[ ! -e "$filename" ]]; then
      if [ $contains_newline_chars -eq 1 ]; then
        filename_being_deleted+=$'\n'
        filename_being_deleted+="$filename"
      else
        filename_being_deleted="$filename"
      fi
      attempt=$(balooctl6 clear "$filename_being_deleted")
      echo "$attempt"
      if [[ $attempt == "File not found on filesystem or in DB"* ]]; then
        contains_newline_chars=1
      else
        contains_newline_chars=0
        filename_being_deleted=""
      fi
    fi
  done
done

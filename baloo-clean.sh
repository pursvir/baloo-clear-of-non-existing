#!/usr/bin/env sh

balooctl6 disable
declare -a file_types=(
  "Audio"
  "Documents"
  "Media"
  "Images"
)
for file_type in "${file_types[@]}"; do
  baloosearch6 "type:$file_type" | head -n -1 | while read filename; do
    if [ ! -f "$filename" ]; then
      balooctl6 clear "$filename"
    fi
  done
done
balooctl6 enable

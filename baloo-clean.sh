#!/usr/bin/env bash

cleared_successfully() {
  # Args: $1 - file path.
  local attempt
  attempt=$(balooctl6 clear "$1" 2>/dev/null)
  if [[ $attempt == "File not found on filesystem or in DB"* ]]; then
    echo 0
  else
    echo 1
  fi
}

file_types=(
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
zombie_entries=()

for file_type in "${file_types[@]}"; do
  while read -r entry; do
    if [[ -z "$entry" && contains_newline_chars -eq 0 ]]; then
      continue
    fi
    if [[ "$entry" == ${HOME}* ]]; then
      if [[ -e "$filename_being_deleted" ]]; then
        zombie_entries+=("$filename_being_deleted")
      fi
      contains_newline_chars=0
    fi
    if [[ ! -e "$entry" ]]; then
      if [ $contains_newline_chars -eq 1 ]; then
        filename_being_deleted+=$'\n'
        filename_being_deleted+="$entry"
      else
        filename_being_deleted="$entry"
      fi
      success=$(cleared_successfully "$filename_being_deleted")
      if [[ "$success" == "0" ]]; then
        contains_newline_chars=1
      else
        echo "Removed $filename_being_deleted from index"
        contains_newline_chars=0
        filename_being_deleted=""
      fi
    fi
  done < <(baloosearch6 "type:$file_type" | head -n -1)
done

for zombie_entry in "${zombie_entries[@]}"; do
  IFS='/' read -ra path_levels <<< "$zombie_entry"
  path_levels[1]=()
  filename_being_deleted=""
  for path_level in "${path_levels[@]}"; do
    success=0
    filename_being_deleted+="/$path_level"
    if [[ ! -e "$filename_being_deleted" ]]; then
      if [[ "$(cleared_successfully "$filename_being_deleted")" -eq 0 ]]; then
        success=1
        break
      fi
    fi
  done
  if [[ "$success" == 0 ]]; then
    echo "Failed to delete upper paths of entry $zombie_entry!"
  else
    echo "Removed $filename_being_deleted of entry $zombie_entry"
  fi
done

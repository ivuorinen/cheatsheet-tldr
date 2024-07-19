#!/usr/bin/env bash
# Create cheat/cheat compatible versions of the english tldr pages
# Copyright (c) 2024 Ismo Vuorinen <https://github.com/ivuorinen>
# Script licensed under the MIT License
#  https://github.com/ivuorinen/cheatsheet-tldr/blob/main/.github/LICENSE.md
# TLDR pages licensed under CC-BY-4.0
#  https://github.com/tldr-pages/tldr/blob/main/LICENSE.md

# To run debug mode, run script like this: DEGUG=1 ./run.sh
DEBUG="${DEBUG:-0}"
# To run in verbose mode, run script like this: VERBOSE=1 ./run.sh
VERBOSE="${VERBOSE:-0}"

# Function to print an error message and exit
# $1 - error message (string)
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Print an error message
# $1 - error message (string)
msg_err() {
  echo "Error: $1" >&2
}

# Print a warning message
# $1 - warning message (string)
msg_warn() {
  echo "Warning: $1" >&2
}

# Print an ok message
# $1 - ok message (string)
msg_ok() {
  echo "OK: $1" >&2
}

# Debug message
# $1 - debug message (string)
msg_debug() {
  if [[ $DEBUG -eq 1 ]]; then
    echo "DEBUG: $1" >&2
  fi
}

# Return sha256sum for a file
# $1 - filename (string)
get_sha256sum() {
  [[ $DEBUG -eq 1 ]] && msg_debug "Getting sha256sum for: $1"
  local file="$1"
  sha256sum "$file" | awk '{print $1}'
}

# Check if a file is replaceable
# $1 - source file (string)
# $2 - destination file (string)
# Returns 1 when replaceable, 0 when not replaceable.
is_replaceable() {
  local file1="$1"
  local file2="$2"
  local file1_hash
  local file2_hash

  [[ $DEGUG -eq 1 ]] && msg_debug "Checking if files are replaceable: $file1, $file2"

  if [[ ! -r "$file1" ]]; then
    [[ $VERBOSE -eq 1 ]] && msg_err "File 1 ($file1) does not exist"
    return 0
  fi

  if [[ ! -r "$file2" ]]; then
    [[ $VERBOSE -eq 1 ]] && msg_warn "File 2 ($file2) does not exist, replaceable"
    return 1
  fi

  file1_hash=$(get_sha256sum "$file1")
  file2_hash=$(get_sha256sum "$file2")

  if [[ -z "$file1_hash" ]]; then
    [[ $VERBOSE -eq 1 ]] && msg_err "Could not get hash for file 1 ($file1)"
    return 0
  fi

  if [[ -z "$file2_hash" ]]; then
    [[ $VERBOSE -eq 1 ]] && msg_warn "Could not get hash for file 2 ($file2), replaceable"
    return 1
  fi

  if [[ "$file1_hash" == "$file2_hash" ]]; then
    [[ $VERBOSE -eq 1 ]] && msg_ok "Files match, not replaceable: $file1"
    return 0
  fi

  [[ $VERBOSE -eq 1 ]] && msg_warn "Files do not match ($file1_hash != $file2_hash), replaceable"
  return 1
}

# Function to clone the TLDR repository
# $1 - repository URL (string)
clone_repo() {
  [[ $DEBUG -eq 1 ]] && msg_debug "Cloning repository: $1"
  local repo_url="$1"
  local dest_dir="$2"
  git clone --depth 1 --single-branch -q "$repo_url" "$dest_dir" || error_exit "Failed to clone repository"
}

# Function to update the markdown files
# $1 - source directory (string)
# $2 - destination directory (string)
# $3 - syntax (string)
# $4 - source (string)
update_markdown_files() {
  [[ $DEBUG -eq 1 ]] && msg_debug "Updating markdown files"

  local src_dir="$1"
  local dest_dir="$2"
  local syntax="$3"
  local source="$4"

  for d in "$src_dir"/pages/*; do
    [[ $VERBOSE -eq 1 ]] && msg_debug "Processing directory: $d"

    local dirname
    dirname=$(basename "$d")
    local section_dir="${dest_dir}/${dirname}"
    [ "$dirname" = "common" ] && section_dir="${dest_dir}"

    local tldr_tags="tags: [tldr, $dirname]"

    if [ ! -d "$section_dir" ]; then
      mkdir -p "$section_dir" || error_exit "Failed to create directory: $section_dir"
    fi

    for file in "$d"/*.md; do
      [[ $DEBUG -eq 1 ]] && msg_debug "Processing file: $file"
      local basename
      basename=$(basename "$file" .md)
      local tldr_file="${section_dir}/${basename}"

      if [ -f "$file" ] && [ '---' != "$(head -1 <"$file")" ]; then
        echo -e "---\n$syntax\n$tldr_tags\n$source\n---\n$(cat "$file")" >"$file"
      fi

      is_replaceable "$file" "$tldr_file"
      local override=$?

      if [ "$override" -ne 0 ]; then
        # Remove full path from the file and set as relative path for message
        local tldr_file_rel
        tldr_file_rel="${tldr_file#$dest_dir/}"

        cp "$file" "$tldr_file" && echo "Updated: $tldr_file_rel" ||
          error_exit "Failed to copy file: $file to $tldr_file"
      fi
    done
  done
}

# Main script logic
main() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" ||
    error_exit "Failed to determine current directory"

  msg_debug "Running: $dir/run.sh"
  msg_debug "Working directory: $dir"

  local tldr_git="https://github.com/tldr-pages/tldr.git"
  local tldr_source="source: $tldr_git"
  local tldr_syntax="syntax: markdown"
  local tldr_temp_dir
  tldr_temp_dir="$(realpath "$dir"/..)/__tldr-temp"
  local tldr_cheat_dest
  tldr_cheat_dest="$(realpath "$dir"/../tldr)"

  if [ -d "$tldr_temp_dir" ]; then
    rm -rf "$tldr_temp_dir" ||
      error_exit "Failed to remove directory: $tldr_temp_dir"
  fi

  msg_debug "TLDR_TEMP_DIR: $tldr_temp_dir"
  msg_debug "TLDR_CHEAT_DEST: $tldr_cheat_dest"

  clone_repo "$tldr_git" "$tldr_temp_dir"

  rm -rf "$tldr_temp_dir/pages.*" ||
    error_exit "Failed to remove translations (pages.*) from $tldr_temp_dir"

  update_markdown_files "$tldr_temp_dir" "$tldr_cheat_dest" "$tldr_syntax" "$tldr_source"

  rm -rf "$tldr_temp_dir" ||
    error_exit "Failed to remove directory: $tldr_temp_dir"
}

# Run the main function
main "$@"

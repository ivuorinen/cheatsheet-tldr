#!/usr/bin/env bash
# Create cheat/cheat compatible versions of the english tldr pages
# Copyright (c) 2024 Ismo Vuorinen <https://github.com/ivuorinen>
# Script licensed under the MIT License
#  https://github.com/ivuorinen/cheatsheet-tldr/blob/main/.github/LICENSE.md
# TLDR pages licensed under CC-BY-4.0
#  https://github.com/tldr-pages/tldr/blob/main/LICENSE.md

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Running: $DIR/run.sh"
echo "Working directory: $DIR"

source "$DIR/shared.sh"

TLDR_GIT="https://github.com/tldr-pages/tldr.git"
TLDR_SOURCE="source: $TLDR_GIT"
TLDR_SYNTAX="syntax: markdown"
TLDR_TEMP_DIR="$(realpath "$DIR"/..)/__tldr-temp"
TLDR_CHEAT_DEST="$(realpath "$DIR"/../)"

if [ -d "$TLDR_TEMP_DIR" ]; then
  rm -rf "$TLDR_TEMP_DIR"
fi

echo "TLDR_TEMP_DIR: $TLDR_TEMP_DIR"
echo "TLDR_CHEAT_DEST: $TLDR_CHEAT_DEST"

git clone \
  --depth 1 \
  --single-branch \
  -q "$TLDR_GIT" "$TLDR_TEMP_DIR" || exit 1

rm -rf "$TLDR_TEMP_DIR/pages.*"

for d in "$TLDR_TEMP_DIR"/pages/*; do
  DIRNAME=$(basename "$d")
  # echo "-> $DIRNAME ($d)"

  SECTION_DIR="${TLDR_CHEAT_DEST}/$DIRNAME"

  [ "$DIRNAME" = "common" ] && SECTION_DIR="${TLDR_CHEAT_DEST}"

  TLDR_TAGS="tags: [tldr, $DIRNAME]"

  if [ ! -d "$SECTION_DIR" ]; then
    mkdir -p "$SECTION_DIR"
  fi

  for FILE in "$d"/*.md; do
    BASENAME=$(basename "$FILE" .md)
    # FILENAME="${BASENAME%%.*}"
    # echo "-> $FILE = $FILENAME"
    TLDR_FILE="$SECTION_DIR/${BASENAME}"
    # echo "-> dest: $TLDR_FILE"

    # Update the original file for making the replaceable value comparable
    if [ -f "$FILE" ] && [ '---' != "$(head -1 < "$FILE")" ]; then
      echo -e "---\n$TLDR_SYNTAX\n$TLDR_TAGS\n$TLDR_SOURCE\n---\n$(cat "$FILE")" > "$FILE"
    fi

    replaceable "$FILE" "$TLDR_FILE"

    override=$?
    if [ "$override" -ne 0 ]; then
      cp "$FILE" "$TLDR_FILE" && echo "Updated: $TLDR_FILE"
    fi

  done
done

rm -rf "$TLDR_TEMP_DIR"

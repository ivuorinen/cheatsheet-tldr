#!/usr/bin/env bash

# return sha256sum for file
# $1 - filename (string)
function get_sha256sum()
{
  sha256sum "$1" | head -c 64
}

# Replaceable file
#
# $1 - filename (string)
# $2 - filename (string)
#
# Returns 1 when replaceable, 0 when not replaceable.
function replaceable()
{
  FILE1="$1"
  FILE2="$2"

  [[ ! -r "$FILE1" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "File 1 ($FILE1) does not exist"
    return 0
  }
  [[ ! -r "$FILE2" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "File 2 ($FILE2) does not exist, replaceable"
    return 1
  }

  FILE1_HASH=$(get_sha256sum "$FILE1")
  FILE2_HASH=$(get_sha256sum "$FILE2")

  [[ $FILE1_HASH = "" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "Could not get hash for file 1 ($FILE1)"
    return 0
  }
  [[ $FILE2_HASH = "" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_err "Could not get hash for file 2 ($FILE2), replaceable"
    return 1
  }

  [[ "$FILE1_HASH" == "$FILE2_HASH" ]] && {
    [[ $VERBOSE -eq 1 ]] && msg_ok "Files match, not replaceable: $FILE1"
    return 0
  }

  [[ $VERBOSE -eq 1 ]] && msg_warn "Files do not match ($FILE1_HASH != $FILE2_HASH), replaceable"

  return 1
}

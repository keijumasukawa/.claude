#!/usr/bin/env bash

is_git_commit() {
  printf '%s' "$1" | grep -Eq 'git ([^"|;&]* )?commit'
}

commit_root() {
  local target
  target=$(printf '%s' "$1" | sed -n 's/.*git -C \([^ "]*\).*/\1/p' | head -1)
  printf '%s' "${target:-.}"
}

list_commit_files() {
  local input=$1 root files addpaths
  root=$(commit_root "$input")

  if printf '%s' "$input" | grep -Eq 'git ([^"|;&]* )?add [^"|;&]*(-A|--all)([ "]|$)|git ([^"|;&]* )?add +\.[" ;&]|commit[^"|;&]* (-a|-am|--all)([ "]|$)'; then
    files=$(git -C "$root" status --porcelain 2>/dev/null | sed 's/^...//; s/.* -> //')
  else
    files=$(git -C "$root" diff --cached --name-only 2>/dev/null)
    addpaths=$(printf '%s' "$input" | grep -oE 'git ([^"|;&]* )?add [^"|;&]*' | sed 's/.* add //' | tr ' ' '\n' | grep -Ev '^-|^$')
    files=$(printf '%s\n%s\n' "$files" "$addpaths")
  fi

  printf '%s\n' "$files" | grep -v '^$'
}

list_branch_files() {
  local root base
  root=$(commit_root "$1")

  base=$(git -C "$root" rev-parse --verify --quiet origin/main)
  [ -z "$base" ] && base=$(git -C "$root" rev-parse --verify --quiet main)
  [ -z "$base" ] && return 0
  git -C "$root" rev-parse --verify --quiet HEAD > /dev/null || return 0

  git -C "$root" diff --name-only "$base...HEAD" 2>/dev/null
}

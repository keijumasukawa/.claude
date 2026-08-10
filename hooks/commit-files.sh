#!/usr/bin/env bash
# git commit を実行する Bash ツール入力から、コミット対象のファイルを求める
# 入力 JSON は追加ツールへの依存を避けるため文字列検索で判定する

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

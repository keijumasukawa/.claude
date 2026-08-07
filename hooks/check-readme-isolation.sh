#!/usr/bin/env bash
# git commit 実行前に README.md と他ファイルの混在を検査し、混在時はコミットを拒否する
# 入力 JSON は追加ツールへの依存を避けるため文字列検索で判定する

input=$(cat)

printf '%s' "$input" | grep -Eq 'git ([^"|;&]* )?commit' || exit 0

target=$(printf '%s' "$input" | sed -n 's/.*git -C \([^ "]*\).*/\1/p' | head -1)

run_git() {
  if [ -n "$target" ]; then git -C "$target" "$@"; else git "$@"; fi
}

if printf '%s' "$input" | grep -Eq 'git ([^"|;&]* )?add [^"|;&]*(-A|--all)([ "]|$)|git ([^"|;&]* )?add +\.[" ;&]|commit[^"|;&]* (-a|-am|--all)([ "]|$)'; then
  files=$(run_git status --porcelain 2>/dev/null | sed 's/^...//; s/.* -> //')
else
  files=$(run_git diff --cached --name-only 2>/dev/null)
  addpaths=$(printf '%s' "$input" | grep -oE 'git ([^"|;&]* )?add [^"|;&]*' | sed 's/.* add //' | tr ' ' '\n' | grep -Ev '^-|^$')
  files=$(printf '%s\n%s\n' "$files" "$addpaths")
fi

files=$(printf '%s\n' "$files" | grep -v '^$')
[ -z "$files" ] && exit 0

readme=$(printf '%s\n' "$files" | grep -cx 'README.md')
others=$(printf '%s\n' "$files" | grep -cvx 'README.md')

if [ "$readme" -gt 0 ] && [ "$others" -gt 0 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"README.md と他のファイルが同一コミットに含まれています。Git 運用規程「README の例外」に従い、README は docs/readme ブランチの単独プルリクエストで分離してください。"}}'
fi
exit 0

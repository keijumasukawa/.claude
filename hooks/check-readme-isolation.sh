#!/usr/bin/env bash
# git commit 実行前に README.md と他ファイルの混在を検査し、混在時はコミットを拒否する

input=$(cat)

. "$(dirname "$0")/commit-files.sh"

is_git_commit "$input" || exit 0

files=$(list_commit_files "$input")
[ -z "$files" ] && exit 0

readme=$(printf '%s\n' "$files" | grep -cx 'README.md')
others=$(printf '%s\n' "$files" | grep -cvx 'README.md')

if [ "$readme" -gt 0 ] && [ "$others" -gt 0 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"README.md と他のファイルが同一コミットに含まれている。リポジトリ運用規程「README の例外」により、README は docs/readme ブランチの単独プルリクエストで分離する。"}}'
fi
exit 0

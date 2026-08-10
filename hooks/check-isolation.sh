#!/usr/bin/env bash

input=$(cat)

. "$(dirname "$0")/commit-files.sh"

is_git_commit "$input" || exit 0

files=$(list_commit_files "$input")
[ -z "$files" ] && exit 0

classify() {
  case $1 in
    README.md) printf 'README' ;;
    .github/workflows/*) printf 'ワークフローの定義' ;;
    eslint.config.*|.eslintrc*|prettier.config.*|.prettierrc*|tsconfig*.json) printf '検査の設定' ;;
    */eslint.config.*|*/.eslintrc*|*/prettier.config.*|*/.prettierrc*|*/tsconfig*.json) printf '検査の設定' ;;
    *) printf 'その他のファイル' ;;
  esac
}

kinds=$(while IFS= read -r file; do classify "$file"; printf '\n'; done <<< "$files" | sort -u)
[ "$(printf '%s\n' "$kinds" | grep -c .)" -le 1 ] && exit 0

detail=$(printf '%s\n' "$kinds" | awk 'NR>1 { printf "・" } { printf "%s", $0 }')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s が同一コミットに含まれている。リポジトリ運用規程「プルリクエスト」により、対象ごとに分離する。"}}' "$detail"
exit 0

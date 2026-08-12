#!/usr/bin/env bash

input=$(cat)

. "$(dirname "$0")/commit-files.sh"

is_git_commit "$input" || exit 0

files=$(printf '%s\n%s\n' "$(list_commit_files "$input")" "$(list_branch_files "$input")" | grep -v '^$' | sort -u)
[ -z "$files" ] && exit 0

classify() {
  case $1 in
    README.md) printf 'README' ;;
    .github/workflows/*) printf 'ワークフローの定義' ;;
    package.json|pnpm-lock.yaml|package-lock.json|yarn.lock) printf '補助ファイル' ;;
    */package.json|*/pnpm-lock.yaml|*/package-lock.json|*/yarn.lock) printf '補助ファイル' ;;
    eslint.config.*|.eslintrc*|.eslintignore|prettier.config.*|.prettierrc*|.prettierignore|tsconfig*.json) printf '検査の設定' ;;
    */eslint.config.*|*/.eslintrc*|*/.eslintignore|*/prettier.config.*|*/.prettierrc*|*/.prettierignore|*/tsconfig*.json) printf '検査の設定' ;;
    *) printf 'その他のファイル' ;;
  esac
}

kinds=$(while IFS= read -r file; do classify "$file"; printf '\n'; done <<< "$files" | sort -u)
count() { printf '%s\n' "$1" | grep -c .; }

if printf '%s\n' "$kinds" | grep -qx 'README'; then
  [ "$(count "$kinds")" -le 1 ] && exit 0
else
  kinds=$(printf '%s\n' "$kinds" | grep -vx '補助ファイル')
  [ "$(count "$kinds")" -le 1 ] && exit 0
fi

detail=$(printf '%s\n' "$kinds" | awk 'NR>1 { printf "・" } { printf "%s", $0 }')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s が同一コミットに含まれている。ワークフロー規程「プルリクエスト」により、対象ごとに分離する。"}}' "$detail"
exit 0

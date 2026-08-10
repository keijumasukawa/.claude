#!/usr/bin/env bash

input=$(cat)

. "$(dirname "$0")/commit-files.sh"

is_git_commit "$input" || exit 0

files=$(list_commit_files "$input" | grep -E '\.(md|sh|json|ya?ml)$')
[ -z "$files" ] && exit 0

mapfile -t rules < <(grep -Ev '^#|^$' "$(dirname "$0")/notation-rules.tsv")

root=$(commit_root "$input")
violations=""

while IFS= read -r file; do
  path="$root/$file"
  [ -f "$path" ] || continue
  for rule in "${rules[@]}"; do
    pattern=${rule%%$'\t'*}
    message=${rule#*$'\t'}
    for line in $(grep -nE "$pattern" "$path" | cut -d: -f1); do
      violations="${violations}${file}:${line} ${message}"$'\n'
    done
  done
done <<< "$files"

[ -z "$violations" ] && exit 0

detail=$(printf '%s' "$violations" | sort -u -t: -k1,2 | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"文書規程「表記」「文体」に反する記述がある。\\n%s"}}' "$detail"
exit 0

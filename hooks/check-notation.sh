#!/usr/bin/env bash
# git commit 実行前に文書の表記と文体を検査し、文書規程に反する語を含む場合はコミットを拒否する
# 検出語を列挙する本スクリプト自身が対象とならないよう、検査対象は Markdown に限る

input=$(cat)

. "$(dirname "$0")/commit-files.sh"

is_git_commit "$input" || exit 0

files=$(list_commit_files "$input" | grep -E '\.md$')
[ -z "$files" ] && exit 0

# 文字クラスに全角文字を置くとロケールによりバイト単位で照合されるため、選択肢で記述する
rules=(
  $'および\t「および」→「及び」'
  $'または\t「または」→「又は」'
  $'ならびに\t「ならびに」→「並びに」'
  $'もしくは\t「もしくは」→「若しくは」'
  $'但し\t「但し」→「ただし」'
  $'尚(、| )\t「尚」→「なお」'
  $'且つ\t「且つ」→「かつ」'
  $'(する|した|る|い|の)事(を|は|が|に|で|も|と|、|。)\t形式名詞の「事」→「こと」'
  $'(の|な|る|た)為(に|の|、|。)\t形式名詞の「為」→「ため」'
  $'すべて\t「すべて」→「全て」'
  $'など\t「など」→「等」'
  $'[1-9]つ\t訓による数え方は漢数字'
  $'(，|．)\t読点は「、」、句点は「。」'
  $'(（|）)\t括弧は半角'
  $'出来(る|ない|た|ず)\t「出来る」→「できる」'
  $'無い\t「無い」→「ない」'
  $'様々\t「様々」→「さまざま」'
  $'予め\t「予め」→「あらかじめ」'
  $'頂(く|き|け)\t「頂く」→「いただく」'
  $'(です|ます|ません)\t常体で記述する'
  $'ください\t常体で記述する'
)

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

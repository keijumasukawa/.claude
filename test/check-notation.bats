#!/usr/bin/env bats

setup() {
  HOOK="$BATS_TEST_DIRNAME/../hooks/check-notation.sh"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  git -C "$REPO" init -q
  git -C "$REPO" config user.email you@example.com
  git -C "$REPO" config user.name tester
}

input() {
  printf '{"tool_input":{"command":"git -C %s commit -m x"}}' "$REPO"
}

stage() {
  printf '%s\n' "$2" > "$REPO/$1"
  git -C "$REPO" reset -q
  git -C "$REPO" add "$1"
}

@test "規則に反しない文書を通過させる" {
  stage ok.md "全ての項目を記入する。"
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "表記に反する語を検出する" {
  stage ng.md "設定および雛形を用いる。"
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *"「および」→「及び」"* ]]
}

@test "文体に反する語を検出する" {
  stage ng.md "検査を実行しました。"
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *"常体で記述する"* ]]
}

@test "検査の対象外の形式を通過させる" {
  stage ok.txt "設定および雛形を用いる。"
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

#!/usr/bin/env bats

setup() {
  HOOK="$BATS_TEST_DIRNAME/../hooks/check-isolation.sh"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/.github/workflows"
  git -C "$REPO" init -q
  git -C "$REPO" config user.email you@example.com
  git -C "$REPO" config user.name tester
  printf 'x\n' > "$REPO/README.md"
  printf 'x\n' > "$REPO/CLAUDE.md"
  printf 'x\n' > "$REPO/.github/workflows/ci.yml"
  printf '{}\n' > "$REPO/tsconfig.json"
}

input() {
  printf '{"tool_input":{"command":"git -C %s commit -m x"}}' "$REPO"
}

stage() {
  git -C "$REPO" reset -q
  git -C "$REPO" add "$@"
}

@test "同一の分類のみの場合は通過する" {
  stage README.md
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "README と他のファイルの混在を拒否する" {
  stage README.md CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "ワークフローの定義と他のファイルの混在を拒否する" {
  stage .github/workflows/ci.yml CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "検査の設定と他のファイルの混在を拒否する" {
  stage tsconfig.json CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

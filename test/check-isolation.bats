#!/usr/bin/env bats

setup() {
  HOOK="$BATS_TEST_DIRNAME/../hooks/check-isolation.sh"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/.github/workflows"
  git -C "$REPO" init -q -b main
  git -C "$REPO" config user.email you@example.com
  git -C "$REPO" config user.name tester
  printf 'x\n' > "$REPO/README.md"
  printf 'x\n' > "$REPO/CLAUDE.md"
  printf 'x\n' > "$REPO/other.md"
  printf 'x\n' > "$REPO/.github/workflows/ci.yml"
  printf '{}\n' > "$REPO/tsconfig.json"
  printf 'x\n' > "$REPO/.prettierignore"
  printf '{}\n' > "$REPO/package.json"
  printf 'x\n' > "$REPO/pnpm-lock.yaml"
  git -C "$REPO" add -A
  git -C "$REPO" commit -q -m x
  git -C "$REPO" switch -q -c work
}

input() {
  printf '{"tool_input":{"command":"git -C %s commit -m x"}}' "$REPO"
}

change() {
  local file
  for file in "$@"; do
    printf 'y\n' >> "$REPO/$file"
    git -C "$REPO" add "$file"
  done
}

commit_change() {
  change "$1"
  git -C "$REPO" commit -q -m x
}

@test "同一の分類のみの場合は通過する" {
  change README.md
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "README と他のファイルの混在を拒否する" {
  change README.md CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "ワークフローの定義と他のファイルの混在を拒否する" {
  change .github/workflows/ci.yml CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "検査の設定と他のファイルの混在を拒否する" {
  change tsconfig.json CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "作業ブランチの先行するコミットとの混在を拒否する" {
  commit_change .github/workflows/ci.yml
  change CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "整形の対象範囲の設定を検査の設定として扱う" {
  change .prettierignore CLAUDE.md
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "検査の設定と補助ファイルの同居を通過させる" {
  change tsconfig.json .prettierignore package.json pnpm-lock.yaml
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "その他のファイルと補助ファイルの同居を通過させる" {
  change CLAUDE.md package.json pnpm-lock.yaml
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "README と補助ファイルの混在を拒否する" {
  change README.md package.json
  run bash "$HOOK" <<< "$(input)"
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "補助ファイルのみの場合は通過する" {
  change package.json pnpm-lock.yaml
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

@test "作業ブランチが同一の分類のみの場合は通過する" {
  commit_change CLAUDE.md
  change other.md
  run bash "$HOOK" <<< "$(input)"
  [ -z "$output" ]
}

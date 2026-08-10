#!/usr/bin/env bats

setup() {
  . "$BATS_TEST_DIRNAME/../hooks/commit-files.sh"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  git -C "$REPO" init -q
  git -C "$REPO" config user.email you@example.com
  git -C "$REPO" config user.name tester
}

input() {
  printf '{"tool_input":{"command":"%s"}}' "$1"
}

@test "コミットを実行する入力を検出する" {
  run is_git_commit "$(input "git commit -m x")"
  [ "$status" -eq 0 ]
}

@test "コミットを実行しない入力を検出しない" {
  run is_git_commit "$(input "git status")"
  [ "$status" -ne 0 ]
}

@test "位置の指定からリポジトリの位置を求める" {
  run commit_root "$(input "git -C /tmp/foo commit -m x")"
  [ "$output" = "/tmp/foo" ]
}

@test "位置の指定がない場合は現在のディレクトリとする" {
  run commit_root "$(input "git commit -m x")"
  [ "$output" = "." ]
}

@test "ステージ済みのファイルを列挙する" {
  printf 'x\n' > "$REPO/a.md"
  git -C "$REPO" add a.md
  run list_commit_files "$(input "git -C $REPO commit -m x")"
  [ "$output" = "a.md" ]
}

@test "一括での追加を伴う場合は作業ツリーの変更を列挙する" {
  printf 'x\n' > "$REPO/b.md"
  run list_commit_files "$(input "git -C $REPO add -A && git -C $REPO commit -m x")"
  [ "$output" = "b.md" ]
}

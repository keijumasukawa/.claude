---
name: init-repo
description: GitHub リポジトリを初期化する。新しいリポジトリの作成・初期設定を行うときに使用する。
---

リポジトリを次の手順で初期化する。各手順は Issue に紐づけない。手順1と手順2はコマンドを提示し、実行は利用者が行う。

1. リポジトリを作成し、空のコミットで `main` を作成して push する。これによりプルリクエストが作成可能になる。
2. リポジトリの設定を適用する。
3. 空の README.md を `readme` スキルの手順で追加する。

手順1のコマンド(`<owner>/<repo>` は対象に、`<可視性>` は `--public`・`--private`・`--internal` のいずれかに置き換える):

```bash
git init -b main
git commit --allow-empty -m "chore: リポジトリを初期化"
gh repo create <owner>/<repo> <可視性> --source . --push
```

手順2のコマンド(`<owner>/<repo>` は対象に置き換える):

```bash
gh repo edit <owner>/<repo> --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --squash-merge-commit-message pr-title --delete-branch-on-merge
```

```bash
gh api -X POST repos/<owner>/<repo>/rulesets --input - <<'EOF'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "allowed_merge_methods": ["squash"]
      }
    },
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ]
}
EOF
```
---
name: init-repo
description: GitHub リポジトリを初期化する。新しいリポジトリの作成・初期設定を行うときに使用する。
---

リポジトリを次の手順で初期化する。各手順は Issue に紐づけない。

1. リポジトリを作成し、空のコミット(`git commit --allow-empty`、メッセージ `chore: リポジトリを初期化`)で `main` を作成して push する。空コミットのみの初回 push は、リポジトリ作成に伴う操作として承認を得て実行してよい。これによりプルリクエストが作成可能になる。
2. Git 運用規程「リポジトリの設定」の設定を、後述のコマンドで適用する。
3. 空の README.md を `docs/readme` ブランチの単独プルリクエスト(コミットメッセージおよびタイトルは `docs: README を追加`)で登録する。本文はテンプレートの全項目を次の内容で簡素に埋め、詳述しない。
   - 目的: README の登録
   - 変更内容: README の登録
   - 確認方法: リポジトリのトップページでの表示確認

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
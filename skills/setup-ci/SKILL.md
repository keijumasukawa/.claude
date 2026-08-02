---
name: setup-ci
description: GitHub Actions の CI を導入する。検証(lint・型検査・テスト)の自動実行を追加するときに使用する。
---

CI を次の手順で導入する。

1. [template.yml](template.yml) を雛形に `.github/workflows/ci.yml` を追加し、プルリクエストで登録する。検証コマンドはリポジトリの構成に合わせる。
2. プルリクエスト上で CI の通過を確認し、マージする。
3. CI 必須のルールセットを次のコマンドで追加する。

```bash
gh api -X POST repos/<owner>/<repo>/rulesets --input - <<'EOF'
{
  "name": "require-ci",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [{ "context": "verify" }]
      }
    }
  ]
}
EOF
```

- pnpm のバージョンは package.json の `packageManager`、Node.js のバージョンは `engines.node` による。記載がなければ追加する。
- CI にシークレットを要する工程を含めない。Dependabot のプルリクエストではシークレットが渡らず、マージ不能になるためである。

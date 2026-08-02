---
name: setup-dependabot
description: 依存関係の自動更新を導入する。Dependabot によるバージョン更新のプルリクエストを有効にするときに使用する。
---

依存関係の自動更新を次の手順で導入する。前提: CI が導入済みであること(更新の検証を CI が担うため)。

1. [dependabot.yml](dependabot.yml) を雛形に `.github/dependabot.yml` を追加し、プルリクエストで登録する。
2. Dependabot のプルリクエストは、CI の通過を確認してマージする。

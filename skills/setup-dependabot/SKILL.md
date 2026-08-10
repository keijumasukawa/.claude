---
name: setup-dependabot
description: 依存関係の自動更新を導入する。Dependabot によるバージョン更新のプルリクエストを有効にするときに使用する。
---

依存関係の自動更新を次の手順で導入する。前提: CI が導入済みであること。

1. [dependabot.yml](dependabot.yml) を雛形に `.github/dependabot.yml` を追加し、プルリクエストを作成する。

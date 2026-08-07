---
name: setup-database
description: データベースの書き込みワークフローを導入する。マイグレーション・シードを GitHub Actions で実行するときに使用する。
---

データベースの書き込みワークフローを次の手順で導入する。前提: CI が導入済みであること。

1. [migrate-database.yml](migrate-database.yml) を雛形に `.github/workflows/migrate-database.yml` を追加する。
2. [seed-database.yml](seed-database.yml) を雛形に `.github/workflows/seed-database.yml` を追加する。
3. 接続情報をリポジトリのシークレットに登録する。登録は利用者が行う。
4. プルリクエストで登録し、CI の通過を確認してマージする。

- 実行は Actions タブの `Run workflow` による。
- 同一のデータベースへ書き込むワークフローは、`concurrency` の `group` を共通にする。
- パッケージの指定および実行コマンドは、プロジェクトの構成に合わせる。

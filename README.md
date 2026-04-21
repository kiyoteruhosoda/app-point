# RewardPoints

RewardPoints は、日常のポイント加算・消費・履歴管理を行う Flutter アプリです。  
単なる家計簿的 UI ではなく、**DDD（Domain-Driven Design）** と **ポリモーフィズム（Polymorphism）** を前提に、変更しやすく壊れにくい設計を目指しています。

---

## ✨ 主な機能

- ユーザーの作成・一覧表示・削除
- ポイントの加算 / 消費
- 履歴編集・削除
- 過去入力理由の再利用
- JSON エクスポート / インポート
- テーマ切り替え（ライト / ダーク / システム）
- デバッグ設定（ログレベル変更など）
- ライセンス・アプリ情報表示

---

## 🧠 設計方針（DDD + Polymorphism）

このプロジェクトは、責務分離を明確にした4層構成です。

- **domain**: 業務ルール（Entity / ValueObject / Repository 抽象）
- **application**: ユースケース（DTO と UseCase で入出力を整理）
- **infrastructure**: DB・設定・OS API への接続実装
- **presentation**: ViewModel + UI（Riverpod）

### ポリモーフィズムの使いどころ

ドメイン層は具象実装を知らず、**Repository の抽象**に依存します。  
たとえば `UserRepository` や `PointEntryRepository` はインターフェースとして定義し、
実体は `SqliteUserRepository` / `SqlitePointEntryRepository` などに差し替え可能です。

これにより以下が実現できます。

- DB 実装変更時の影響局所化
- テスト時のモック差し替え容易化
- プラットフォームごとの実装切り替え

---

## 🏗️ ディレクトリ構成

```text
lib/
  app/
    bootstrap/           # ルーティング・起動
    di/                  # Service Locator（依存解決）
  domain/
    entities/            # 業務エンティティ
    value_objects/       # 値オブジェクト
    repositories/        # 抽象リポジトリ
  application/
    usecases/            # アプリケーションサービス
    dto/                 # 入出力DTO
  infrastructure/
    repositories/        # 抽象の具象実装
    db/sqlite/           # SQLite DAO / Row / Migration
    mappers/             # DB <-> Domain 変換
    files/               # エクスポート入出力
    logging/             # 永続ログ
  presentation/
    pages/               # 画面
    viewmodels/          # 状態管理
    widgets/             # 共通UI
  shared/                # 横断関心（テーマ・設定・エラー等）
```

---

## 🚀 セットアップ

### 前提

- Flutter `>= 3.16.0`
- Dart `>= 3.2.0`

### インストール

```bash
flutter pub get
```

### 実行

```bash
flutter run
```

### テスト

```bash
flutter test
```

---

## 🧪 開発運用（モダン実装のためのルール）

- **ドメイン純度を守る**: domain 層に Flutter / DB 依存を持ち込まない
- **ユースケース中心**: UI から repository を直接触らず UseCase を介する
- **抽象に依存**: 実装詳細は infrastructure に閉じ込める
- **ValueObject 優先**: 識別子やルール値はプリミティブ裸渡しを避ける
- **テストファーストで差し替え可能設計**: interface + mock を基本にする

---

## 🔧 よく使うスクリプト

```bash
# バージョン更新
./scripts/bump_version.sh <new_version>

# BuildInfo 生成
./scripts/generate_build_info.sh

# アイコン生成
python3 scripts/generate_icon.py
```

---

## 📄 ライセンス

`LICENSE` を参照してください。

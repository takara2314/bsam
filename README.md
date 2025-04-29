<div align="center">
<a href="https://github.com/takara2314/bsam">
    <img src="./images/icon.png" width="128" height="128" alt="logo" />
</a>

# Blind Sailing Assist Mie - 視覚障がい者帆走支援アプリ

![Language: Dart](https://img.shields.io/badge/Language-Dart-00b4ab?style=for-the-badge&logo=dart)
![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter-54c5f8?style=for-the-badge&logo=flutter)
![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-bd0000?style=for-the-badge)

</div>

視覚障がいをお持ちの方がセーリング（ヨット競技）を行うのを支援するスマートフォンアプリです。競技中、指定されたマークまでヨットで向かうとき、音声で方向ナビゲーションを行うことで、走行を支援します。マークは風や波の影響で位置が変わるため、最新の位置情報をリアルタイムに選手スマートフォンに送信します。

## 関連リポジトリ

[本部用アプリ](https://github.com/takara2314/bsam-admin)

[サーバー](https://github.com/takara2314/bsam-server)

[レースモニター（外部公開用）](https://github.com/takara2314/bsam-web)

## 環境構築
開発には以下が必要です。
- Flutter 3.29.3 以上

1. はじめにリポジトリをクローンし、依存関係をインストールしてください。

```sh
git clone https://github.com/takara2314/bsam.git

cd bsam

npm install
```

2. 次に .env.sample を .env にコピーし、環境変数の設定を行ってください。

```sh
cp .env.sample .env
```

3. Firebase Consoleから以下のファイルをダウンロードし、適切な場所に配置：
- Android: `google-services.json` → `android/app/` に配置
- iOS: `GoogleService-Info.plist` → `ios/Runner/` に配置

## ライセンス

[GPL-3.0](./LICENSE)

## 開発者

[Takara Hamaguchi](https://github.com/takara2314)

<div align="center">
<small>
© 2022 NPO法人セイラビリティ三重
</small>
</div>

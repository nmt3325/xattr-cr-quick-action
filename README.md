# xattr-cr Quick Action for macOS

Finderで選択したファイル／フォルダから拡張属性を再帰的に削除する、macOS向けFinderクイックアクションです。

## インストール

1. [Releases](../../releases/latest)から`xattr-cr-QuickAction-v3.1.zip`をダウンロードして解凍します。
2. `Install.command`を右クリックし、**開く**を選択します。
3. Finderで項目を選択し、右クリック → **クイックアクション** → **xattr -cr（拡張属性を削除）**を実行します。

設定を開いたままインストールした場合は、一度閉じて開き直してください。

## v3.1.0

- 現行のFinder Quick Action形式で再構築
- Finder表示用の`presentationMode`、`systemImageName`、入力形式を追加
- 有効化設定をBoolean型で保存
- `ContextMenu`／`ServicesMenu`の`presentation_modes`を登録
- LaunchServicesと`pbs`の両方へ再登録
- 古いv2／v3の設定を削除
- 複数選択、成功・失敗通知、実行ログに対応
- 登録状態を確認する`Diagnose.command`を同梱

## ログ

```text
~/Library/Logs/xattr-cr-QuickAction.log
```

## 診断

右クリックメニューに表示されない場合は`Diagnose.command`を実行してください。

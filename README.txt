xattr -cr Finder Quick Action v3.1

Finderで選択したファイル／フォルダから、拡張属性を再帰的に削除します。

導入
1. Install.command を右クリック →「開く」で実行します。
2. 設定を開いていた場合は、一度閉じて開き直します。
3. Finderで対象ファイル／フォルダを選択します。
4. 右クリック →「クイックアクション」→
   「xattr -cr（拡張属性を削除）」を選びます。

v3.1の修正点
- 旧Automatorサービス形式ではなく、現行のFinder Quick Action形式で再構築
- document.wflowをContents直下へ配置
- Finder表示用のpresentationMode、systemImageName、入力形式を追加
- NSIconNameとBNDLパッケージ情報を追加
- 新しいBundle IDで古いv2/v3キャッシュと分離
- 有効化設定を文字列ではなくBooleanで保存
- ContextMenu／ServicesMenuのpresentation_modesを登録
- LaunchServicesとpbsの両方へ再登録
- 複数選択、通知、実行ログに対応

表示されない場合
- Finderで項目を右クリック → クイックアクション → カスタマイズを開きます。
- または システム設定 → キーボード → キーボードショートカット → サービス を確認します。
- 設定を開いたままインストールした場合は、設定を閉じて開き直してください。
- Diagnose.command を実行すると登録状態を確認できます。

ログ
~/Library/Logs/xattr-cr-QuickAction.log

#!/bin/bash
TARGET="$HOME/Library/Services/xattr-cr.workflow"
PBS=/System/Library/CoreServices/pbs
echo '=== xattr-cr Quick Action 診断 ==='
if [ -d "$TARGET" ]; then
  echo "Workflow: OK ($TARGET)"
  /usr/bin/plutil -extract CFBundleIdentifier raw -o - "$TARGET/Contents/Info.plist" 2>/dev/null | /usr/bin/sed 's/^/Bundle ID: /'
  /usr/bin/plutil -extract CFBundleShortVersionString raw -o - "$TARGET/Contents/Info.plist" 2>/dev/null | /usr/bin/sed 's/^/Version: /'
  /usr/bin/plutil -extract workflowMetaData.presentationMode raw -o - "$TARGET/Contents/document.wflow" 2>/dev/null | /usr/bin/sed 's/^/presentationMode: /'
  /usr/bin/plutil -extract workflowMetaData.systemImageName raw -o - "$TARGET/Contents/document.wflow" 2>/dev/null | /usr/bin/sed 's/^/systemImageName: /'
else
  echo "Workflow: NG（未インストール）"
fi
echo
echo 'pbs登録:'
"$PBS" -dump 2>/dev/null | /usr/bin/grep -A16 -B2 'com.local.services.xattrcr.v31' || echo 'NG（登録なし）'
echo
echo '設定値:'
/usr/bin/defaults export pbs - 2>/dev/null | /usr/bin/grep -A22 -B2 'com.local.services.xattrcr.v31' || echo 'NG（設定なし）'
echo
echo 'ログ末尾:'
/usr/bin/tail -10 "$HOME/Library/Logs/xattr-cr-QuickAction.log" 2>/dev/null || echo 'まだ実行ログはありません。'
echo
if [ -t 0 ]; then read -r -p 'Enterキーで閉じます。' _; fi

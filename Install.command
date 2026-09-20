#!/bin/bash
# xattr -cr Finder Quick Action v3.1 installer
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/xattr-cr.workflow"

RH="$(/usr/bin/dscl . -read "/Users/$(/usr/bin/id -un)" NFSHomeDirectory 2>/dev/null | /usr/bin/awk '{print $2}')"
case "$RH" in /Users/*) : ;; *) RH="$HOME" ;; esac
TARGET_DIR="$RH/Library/Services"
TARGET="$TARGET_DIR/xattr-cr.workflow"
PBS=/System/Library/CoreServices/pbs
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET"
if ! /usr/bin/ditto "$SOURCE" "$TARGET"; then
    echo "インストールに失敗しました: $TARGET" >&2
    exit 1
fi
/usr/bin/xattr -cr "$TARGET" 2>/dev/null || true
/bin/chmod -R u+rwX "$TARGET" 2>/dev/null || true
/usr/bin/touch "$TARGET"

PLIST="$TARGET/Contents/Info.plist"
TITLE="$(/usr/bin/plutil -extract NSServices.0.NSMenuItem.default raw -o - "$PLIST" 2>/dev/null)"
BID="$(/usr/bin/plutil -extract CFBundleIdentifier raw -o - "$PLIST" 2>/dev/null)"
ENABLE_FAILED=0

# pbs.plistをXMLへ退避してから編集し、既存サービス設定を壊さずBooleanで登録する。
if [ -n "$TITLE" ] && [ -n "$BID" ]; then
    STATUS_KEY="$BID - $TITLE - runWorkflowAsService"
    TMP_PREF="$(/usr/bin/mktemp -t xattrcr-pbs).plist"
    if ! /usr/bin/defaults export pbs "$TMP_PREF" >/dev/null 2>&1; then
        /bin/cat > "$TMP_PREF" <<'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict></dict></plist>
PLIST_EOF
    fi
    /usr/libexec/PlistBuddy -c "Add :NSServicesStatus dict" "$TMP_PREF" >/dev/null 2>&1 || true
    for OLD_BID in com.local.services.xattrcr.v2 com.local.services.xattrcr.v3 com.local.services.xattrcr.v31; do
        OLD_KEY="$OLD_BID - $TITLE - runWorkflowAsService"
        /usr/libexec/PlistBuddy -c "Delete :NSServicesStatus:'$OLD_KEY'" "$TMP_PREF" >/dev/null 2>&1 || true
    done
    if /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY' dict" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY':enabled_context_menu bool true" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY':enabled_services_menu bool true" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY':presentation_modes dict" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY':presentation_modes:ContextMenu bool true" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:'$STATUS_KEY':presentation_modes:ServicesMenu bool true" "$TMP_PREF" >/dev/null 2>&1 \
      && /usr/bin/defaults import pbs "$TMP_PREF" >/dev/null 2>&1; then
        echo "右クリックメニューを有効化しました: $TITLE"
    else
        echo "自動有効化に失敗しました: $TITLE" >&2
        ENABLE_FAILED=1
    fi
    /bin/rm -f "$TMP_PREF"
else
    echo "ワークフローの識別情報を読めません" >&2
    ENABLE_FAILED=1
fi

[ -x "$LSREGISTER" ] && "$LSREGISTER" -f "$TARGET" >/dev/null 2>&1 || true
if [ -x "$PBS" ]; then
    "$PBS" -flush >/dev/null 2>&1 || true
    "$PBS" -read_bundle "$TARGET" >/dev/null 2>&1 || true
    "$PBS" -update >/dev/null 2>&1 || true
fi
/usr/bin/killall -u "$(/usr/bin/id -un)" cfprefsd >/dev/null 2>&1 || true
/usr/bin/killall -HUP Finder >/dev/null 2>&1 || true
/usr/bin/killall Dock >/dev/null 2>&1 || true

echo
echo 'インストール完了（v3.1）'
echo 'Finderで項目を選択し、右クリック → クイックアクション → xattr -cr（拡張属性を削除）を選んでください。'
echo '設定を開いたままの場合は、一度閉じて開き直してください。'
if [ "$ENABLE_FAILED" -ne 0 ]; then
    echo
echo 'Finderで項目を右クリック → クイックアクション → カスタマイズ から手動で有効にしてください。'
fi
echo
echo '実行ログ: ~/Library/Logs/xattr-cr-QuickAction.log'
echo
if [ -t 0 ]; then read -r -p 'Enterキーで閉じます。' _; fi

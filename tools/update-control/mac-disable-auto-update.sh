#!/bin/bash
# Mac(아이맥) + Parallels 자동 업데이트 끄기
#   적용:   sudo bash mac-disable-auto-update.sh
#   되돌리기: sudo bash mac-disable-auto-update.sh --undo
set -e

if [ "$EUID" -ne 0 ]; then
  echo "관리자 권한이 필요합니다: sudo bash $0 $*"; exit 1
fi

UNDO=false
[ "$1" = "--undo" ] && UNDO=true
if $UNDO; then ON=true; OFF_STR=on; else ON=false; OFF_STR=off; fi

SU=/Library/Preferences/com.apple.SoftwareUpdate

echo "▶ macOS 소프트웨어 업데이트: 확인은 하되, 자동 다운로드·설치·재시작 안 함"
defaults write "$SU" AutomaticCheckEnabled -bool true          # 새 업데이트 '알림'은 계속 받음
defaults write "$SU" AutomaticDownload -bool $ON
defaults write "$SU" AutomaticallyInstallMacOSUpdates -bool $ON
defaults write "$SU" ConfigDataInstall -bool $ON
defaults write "$SU" CriticalUpdateInstall -bool $ON
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool $ON   # App Store 앱

echo "▶ Parallels: 가상머신 안 Parallels Tools 자동 업데이트 $OFF_STR"
if command -v prlctl >/dev/null 2>&1; then
  CONSOLE_USER=$(stat -f%Su /dev/console)
  # 가상머신은 사용자 소유이므로 로그인한 사용자 권한으로 실행
  sudo -u "$CONSOLE_USER" prlctl list -a -o uuid --no-header | while read -r VM; do
    [ -z "$VM" ] && continue
    sudo -u "$CONSOLE_USER" prlctl set "$VM" --tools-autoupdate $OFF_STR \
      && echo "  ✓ $VM" || echo "  ⚠ $VM (Pro/Business 에디션 아니면 GUI에서 설정 — README 참고)"
  done
else
  echo "  ⚠ prlctl 명령이 없습니다. README의 Parallels GUI 설정을 따라 하세요."
fi

echo
$UNDO && echo "✅ 자동 업데이트를 원래대로 되돌렸습니다." \
      || echo "✅ 완료. 업데이트는 알림만 오고, 직접 '지금 업데이트'를 눌러야 설치됩니다."
echo "※ Parallels Desktop 앱 자체의 업데이트 설정은 README 2단계(GUI)에서 한 번 꺼 주세요."

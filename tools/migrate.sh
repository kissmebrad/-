#!/bin/bash
# ============================================================
#  애플 메모 → 옵시디언 마크다운 자동 이전 (macOS 전용)
#
#  사용법 (볼트 폴더에서, 터미널):
#     bash tools/migrate.sh
#
#  하는 일:
#   1. 애플 "메모" 앱의 모든 노트를 읽어옴
#   2. 각 노트를 마크다운(.md)으로 변환 (제목/생성일/폴더 보존)
#   3. 10-Notes/애플메모/<원래폴더>/ 아래에 저장
#
#  변환 품질:
#   - pandoc 이 설치돼 있으면 서식(굵게/목록/링크)까지 최대한 보존
#   - 없으면 macOS 내장 textutil 로 깔끔한 텍스트 변환 (항상 동작)
# ============================================================
set -euo pipefail

# --- 경로 설정 ---------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST="$VAULT_DIR/10-Notes/애플메모"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "📓 볼트:      $VAULT_DIR"
echo "📥 저장 위치: $DEST"
echo ""

# --- macOS 확인 --------------------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
  echo "❌ 이 스크립트는 macOS(맥)에서만 동작합니다. 애플 '메모' 앱이 필요해요."
  exit 1
fi

# --- 변환기 감지 -------------------------------------------------------------
if command -v pandoc >/dev/null 2>&1; then
  CONVERTER="pandoc"
  echo "✅ pandoc 발견 — 서식까지 보존합니다."
else
  CONVERTER="textutil"
  echo "ℹ️  pandoc 없음 — macOS 내장 textutil로 변환합니다 (텍스트 위주)."
  echo "   서식까지 원하면:  brew install pandoc  후 다시 실행하세요."
fi
echo ""

# --- 1) 애플 메모 내보내기 ---------------------------------------------------
echo "🔄 애플 메모를 읽는 중… (메모 앱 접근 권한을 물으면 '허용'을 눌러주세요)"
osascript "$SCRIPT_DIR/export-apple-notes.applescript" "$TMP"
echo ""

MANIFEST="$TMP/manifest.tsv"
if [[ ! -s "$MANIFEST" ]]; then
  echo "⚠️  가져온 메모가 없습니다. 메모 앱에 노트가 있는지, iCloud 동기화가 끝났는지 확인하세요."
  exit 0
fi

# --- 2) 각 노트를 마크다운으로 변환 ------------------------------------------
count=0
while IFS=$'\t' read -r idx folder title created; do
  [[ -z "${idx:-}" ]] && continue

  html="$TMP/$idx.html"
  [[ -f "$html" ]] || continue

  # 파일명 안전화 ( / : 등 → - )
  safe_title="$(printf '%s' "$title" | tr '/:\\' '---' | sed 's/[[:cntrl:]]//g')"
  [[ -z "$safe_title" ]] && safe_title="제목없음-$idx"
  safe_folder="$(printf '%s' "$folder" | tr '/:\\' '---' | sed 's/[[:cntrl:]]//g')"
  [[ -z "$safe_folder" ]] && safe_folder="Notes"

  outdir="$DEST/$safe_folder"
  mkdir -p "$outdir"
  outfile="$outdir/$safe_title.md"
  # 이름 충돌 시 인덱스 붙이기
  [[ -e "$outfile" ]] && outfile="$outdir/$safe_title-$idx.md"

  # 본문 변환
  if [[ "$CONVERTER" == "pandoc" ]]; then
    body="$(pandoc -f html -t gfm --wrap=none "$html" 2>/dev/null || true)"
  else
    body="$(textutil -convert txt -stdout "$html" 2>/dev/null || true)"
  fi

  # 프론트매터 + 본문 쓰기
  {
    echo "---"
    echo "title: \"${title//\"/\\\"}\""
    echo "created: ${created:-}"
    echo "source: Apple Notes"
    echo "tags: [애플메모, ${safe_folder}]"
    echo "---"
    echo ""
    echo "$body"
  } > "$outfile"

  count=$((count + 1))
done < "$MANIFEST"

echo "✅ 완료! ${count}개의 메모를 마크다운으로 옮겼습니다."
echo "   → $DEST"
echo ""
echo "다음 단계:"
echo "  1. 옵시디언에서 10-Notes/애플메모 폴더를 확인하세요."
echo "  2. Claude에게: \"10-Notes/애플메모 안의 메모들 주제별로 정리해줘\""

#!/bin/bash
# ============================================================
#  아무 폴더의 텍스트/HTML/마크다운 파일 → 옵시디언 볼트로 가져오기
#
#  삼성 메모, 구글 Keep 내보내기, 기타 앱에서 .txt/.html/.md 로
#  내보낸 파일들을 한 번에 볼트로 옮길 때 사용합니다.
#
#  사용법 (볼트 폴더에서):
#     bash tools/import-files.sh <가져올_폴더_경로>
#  예) bash tools/import-files.sh ~/Downloads/삼성메모내보내기
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST="$VAULT_DIR/10-Notes/가져온메모"

SRC="${1:-}"
if [[ -z "$SRC" || ! -d "$SRC" ]]; then
  echo "❌ 가져올 폴더를 지정하세요.  예) bash tools/import-files.sh ~/Downloads/메모"
  exit 1
fi

if command -v pandoc >/dev/null 2>&1; then HAS_PANDOC=1; else HAS_PANDOC=0; fi
mkdir -p "$DEST"

count=0
# .txt .md .html .htm 파일을 재귀적으로 처리
find "$SRC" -type f \( -iname '*.txt' -o -iname '*.md' -o -iname '*.html' -o -iname '*.htm' \) -print0 |
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  name="${base%.*}"
  ext="${base##*.}"
  outfile="$DEST/$name.md"
  [[ -e "$outfile" ]] && outfile="$DEST/$name-$count.md"

  case "$ext" in
    html|htm|HTML|HTM)
      if [[ "$HAS_PANDOC" == "1" ]]; then
        body="$(pandoc -f html -t gfm --wrap=none "$f" 2>/dev/null || true)"
      elif [[ "$(uname)" == "Darwin" ]]; then
        body="$(textutil -convert txt -stdout "$f" 2>/dev/null || true)"
      else
        body="$(cat "$f")"
      fi
      ;;
    *)
      body="$(cat "$f")"
      ;;
  esac

  {
    echo "---"
    echo "title: \"${name//\"/\\\"}\""
    echo "source: imported"
    echo "tags: [가져온메모]"
    echo "---"
    echo ""
    echo "$body"
  } > "$outfile"

  count=$((count + 1))
  echo "  ✓ $base"
done

echo ""
echo "✅ 완료! 가져온 파일들을 $DEST 에 마크다운으로 저장했습니다."

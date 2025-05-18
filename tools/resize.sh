#!/usr/bin/env bash
#
# 一覧で渡された画像ファイルを一括リサイズして **上書き** します。
# macOS 標準コマンド「sips」を利用します。
#
# 使い方:
#   ./tools/resize.sh img1.jpg img2.png ...
#   ./tools/resize.sh -w 800 *.jpg                 # 幅 800 px に変更
#
# オプション:
#   -w, --width  リサイズ後の最大幅 (デフォルト 1080)
#   -h, --help   使い方表示
#

set -euo pipefail

WIDTH=1080   # デフォルト幅

# --- オプション解析 ----------------------------------------------------------
while [[ $# -gt 0 && $1 == -* ]]; do
  case "$1" in
    -w|--width)
      WIDTH=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-w WIDTH] image1 [image2 ...]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ $# -eq 0 ]]; then
  echo "No images specified." >&2
  exit 1
fi

# --- リサイズ処理 ------------------------------------------------------------
for IMG in "$@"; do
  if [[ ! -f "$IMG" ]]; then
    echo "Skip (not found): $IMG"
    continue
  fi

  # 現在の横幅を取得
  CUR_W=$(sips -g pixelWidth "$IMG" 2>/dev/null | awk '/pixelWidth/ {print $2}')

  if [[ -z "$CUR_W" ]]; then
    echo "Skip (not an image?): $IMG"
    continue
  fi

  if (( CUR_W > WIDTH )); then
    echo "Resizing $IMG  ($CUR_W → $WIDTH px)"
    sips --resampleWidth "$WIDTH" "$IMG" >/dev/null
  else
    echo "Keep     $IMG  ($CUR_W px ≤ $WIDTH px)"
  fi
done

echo "Done."
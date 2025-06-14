#!/bin/sh

CMDNAME=`basename $0`

if [ $# -lt 1 ]; then
  echo "Usage: $CMDNAME slug [IMG_123.JPG IMG_124.JPG ...]" 1>&2
  exit 1
fi

slug=$1
shift

if [ $# -eq 0 ]; then
  files=$(echo originals/*.png)
  if [ "$files" = "originals/*.png" ]; then
    echo "Error: No .png files found in originals/" 1>&2
    exit 1
  fi
  set -- $files
fi

OUTDIR="public/recipes/$slug"
INDIR="originals"

# スラッグ指定の出力ディレクトリが存在する前提
if [ ! -d "$OUTDIR" ]; then
  echo "Error: Output directory $OUTDIR does not exist." 1>&2
  exit 1
fi

for filename in "$@"; do
  src="$INDIR/$(basename "$filename")"
  dest="$OUTDIR/$(basename "$filename")"

  if [ ! -f "$src" ]; then
    echo "Skip: $src not found"
    continue
  fi

  echo "Copying: $src → $dest"
  cp "$src" "$dest"

  echo "Resizing and optimizing: $dest"
  sips -Z 800 "$dest" >/dev/null
  jpegtran -copy none -optimize -outfile "$dest" "$dest"
  sips -g pixelHeight -g pixelWidth "$dest"
done

echo "Done."
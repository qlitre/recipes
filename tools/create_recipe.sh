#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# create_recipe.sh
# ----------------------------------------------------------------------------
# レシピ記事の雛形フォルダを作成します。
# 
#   ./tools/create_recipe.sh slug=<slug> [date=YYYY-MM-DD]
# 
# - slug : 必須。URL 兼ディレクトリ名になります。
# - date : オプション。front‑matter の `date:` に入る日付。
#          省略すると今日の日付 (YYYY-MM-DD) を自動挿入。
#
# 生成されるファイル構成例:
#   app/routes/recipes/your-recipe-slug/
#     └─ index.mdx
#   public/recipes/your-recipe-slug/
#     └─ hero.png  (空のプレースホルダ)
# ----------------------------------------------------------------------------
set -euo pipefail

usage() {
  echo "Usage: $0 slug=<slug> [date=YYYY-MM-DD]" >&2
  exit 1
}

# --- デフォルト値 ------------------------------------------------------------
DATE=$(date +%F)   # 今日の日付 (YYYY-MM-DD)
SLUG=""

# --- 引数パース --------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    slug=*) SLUG="${arg#slug=}" ;;
    date=*) DATE="${arg#date=}" ;;
    *) usage ;;
  esac
done

[[ -z "$SLUG" ]] && usage

# --- ディレクトリ作成 ---------------------------------------------------------
SRC_DIR="app/routes/recipes/${SLUG}"
PUBLIC_DIR="public/recipes/${SLUG}"

for dir in "$SRC_DIR" "$PUBLIC_DIR"; do
  if [[ -d "$dir" ]]; then
    echo "Directory already exists: $dir" >&2
    exit 1
  fi
  mkdir -p "$dir"
done

# --- index.mdx 作成 (app) ----------------------------------------------------
cat > "$SRC_DIR/index.mdx" <<EOF
---
title: レシピタイトル
slug: ${SLUG}
date: ${DATE}
description: "ここに120字以内でレシピの概要を書く"
image: /recipes/${SLUG}/hero.png
servings: 2-3人分
prep_time: 30m
cook_time: "1h"
tags: [カテゴリ1, カテゴリ2]
---

## 材料
-  ... 
-  ... 

### 調味料・たれ原料
- ...
- ... 

### 資材
- 
- 

## 作り方

### 1. **下準備**
- 手順1の説明
![工程画像](/recipes/${SLUG}/step1.png)
- 手順2の説明

### 2. **調理**
- 手順1の説明
![工程画像](/recipes/${SLUG}/step2.png)
- 手順2の説明

### 3. **仕上げ**
- 手順1の説明
![工程画像](/recipes/${SLUG}/step3.png)
- 手順2の説明

## 注意点
- 注意点1
- 注意点2
EOF

# --- 画像プレースホルダー作成 (public) -------------------------------------
touch "$PUBLIC_DIR/hero.png"
touch "$PUBLIC_DIR/step1.png"
touch "$PUBLIC_DIR/step2.png"
touch "$PUBLIC_DIR/step3.png"

echo "✅  Created recipe template"
echo "   - Markdown : $SRC_DIR/index.mdx"
echo "   - ImageDir : $PUBLIC_DIR"
echo "     * hero.png (ヒーロー画像)"
echo "     * step1.png, step2.png, step3.png (工程画像)"
echo ""
echo "📝 Next steps:"
echo "   1. hero.png と step*.png に実際の画像を配置"
echo "   2. index.mdx を編集してレシピ内容を記述"
echo "   3. 必要に応じて追加の step*.png を作成"

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
servings: 2-3人分
prep_time: 30m
cook_time: "1h"
tags: [カテゴリ1, カテゴリ2]
---

![完成イメージ](/recipes/${SLUG}/hero.png)

## 材料
- 材料1 … 分量
- 材料2 … 分量

## 作り方
1. **下準備**
   - 手順1
   - 手順2

2. **調理**
   - 手順1
   - 手順2

3. **仕上げ**
   - 手順1
   - 手順2

## 注意点
- 注意点1
- 注意点2
EOF

# --- hero.png プレースホルダー (public) -------------------------------------
touch "$PUBLIC_DIR/hero.png"

echo "✅  Created recipe template"
echo "   - Markdown : $SRC_DIR/index.mdx"
echo "   - ImageDir : $PUBLIC_DIR (hero.png placeholder)"
echo "   → hero.png と index.mdx を編集してレシピを完成させてください。"

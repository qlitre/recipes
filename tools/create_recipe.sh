#!/usr/bin/env bash
#
# 雛形フォルダを作成するスクリプト
# 使い方:
#   ./tools/create_recipe.sh slug=your-recipe-slug
#     └─ recipes/your-recipe-slug/ 以下に
#        ├─ index.md (テンプレート入り)
#        └─ hero.jpg (空ファイル)
#

set -eu

# --- 引数チェック -------------------------------------------------------------
if [[ $# -ne 1 || $1 != slug=* ]]; then
  echo "Usage: $0 slug=<folder-name>" >&2
  exit 1
fi

SLUG="${1#slug=}"
RECIPE_DIR="recipes/${SLUG}"

# --- ディレクトリ作成 ---------------------------------------------------------
if [[ -d "${RECIPE_DIR}" ]]; then
  echo "Directory already exists: ${RECIPE_DIR}" >&2
  exit 1
fi
mkdir -p "${RECIPE_DIR}"

# --- index.md 作成 -----------------------------------------------------------
cat > "${RECIPE_DIR}/index.md" <<EOF
---
title: レシピタイトル
slug: ${SLUG}
servings: 2-3人分
prep_time: 30m
cook_time: "1h"
tags: [カテゴリ1, カテゴリ2]
---

![完成イメージ](./hero.png)

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

# --- hero.jpg プレースホルダー ----------------------------------------------
touch "${RECIPE_DIR}/hero.jpg"

echo "Created recipe template: ${RECIPE_DIR}"
echo "index.md と hero.jpg を編集してレシピを完成させてください。"
# CLAUDE.md

日本語で回答してください

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

日本語のレシピ管理サイト。HonoX + MDX で構築し、Vite SSG で静的サイト生成して Cloudflare Workers にデプロイする。

## Commands

- `yarn dev` - 開発サーバー起動
- `yarn build` - 本番ビルド（Vite SSG で静的HTML生成 → `dist/`）
- `yarn preview` - `wrangler dev` でビルド結果をローカル確認
- `yarn deploy` - ビルド＋Cloudflare Workers へデプロイ

## Architecture

### ビルドパイプライン

`vite.config.ts` で3つのプラグインを連携:
1. **honox()** - HonoX のファイルベースルーティング
2. **ssg({ entry })** - `app/server.ts` をエントリに静的サイト生成
3. **mdx()** - MDX を `hono/jsx` で処理。`remark-frontmatter` + `remark-mdx-frontmatter` で frontmatter を `export const frontmatter` に変換

### レンダラーの二層構造

- `app/routes/_renderer.tsx` - ルートレイアウト。HTML shell、`<head>`（OGP/Twitter Card メタタグ）、ヘッダー、フッター、ダークモード切り替え
- `app/routes/recipes/_renderer.tsx` - レシピ専用レイアウト。frontmatter からタイトル・日付・メタ情報・ヒーロー画像・タグ・Xシェアボタンを自動レンダリング

レシピMDXの frontmatter は親レイアウトの `_renderer.tsx` に `frontmatter` prop として渡され、OGP メタタグの生成に使われる。

### 型定義

- `app/types.ts` - `Meta` 型（frontmatter のスキーマ）
- `app/global.d.ts` - Hono の `ContextRenderer` を拡張して frontmatter を受け取れるよう宣言

### レシピの追加方法

```bash
./tools/create_recipe.sh slug=recipe-name [date=YYYY-MM-DD]
```

以下が生成される:
- `app/routes/recipes/{slug}/index.mdx` - frontmatter テンプレート付きMDX
- `public/recipes/{slug}/hero.png, step1-3.png` - 画像プレースホルダ

トップページ（`app/routes/index.tsx`）は `import.meta.glob` で全 `.mdx` を eager import し、レシピ一覧を自動生成する。

### 画像処理

`tools/resize.sh` で `originals/` 内の画像を 800px にリサイズ・最適化して `public/recipes/{slug}/` に配置。`sips` と `jpegtran` を使用（macOS 前提）。

### デプロイ

`wrangler.jsonc` で `dist/` を assets ディレクトリに指定。SSG で生成された静的ファイルが Cloudflare Workers の assets として配信される。

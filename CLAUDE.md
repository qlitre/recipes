# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

日本語で回答してください。

## Project Overview

日本語のレシピ管理サイト。HonoX + MDX で構築し、Vite SSG で静的サイト生成して Cloudflare Workers にデプロイする。
公開URL: https://recipes.qlitre.workers.dev

## Commands

- `yarn dev` - 開発サーバー起動
- `yarn build` - 本番ビルド（Vite SSG で静的HTML生成 → `dist/`）
- `yarn preview` - `wrangler dev` でビルド結果をローカル確認（先に `yarn build` が必要）
- `yarn deploy` - ビルド＋Cloudflare Workers へデプロイ

テスト・Lint のスクリプトは無い（prettier は devDependencies にあるが npm script 未定義）。動作確認は `yarn build` の成否と `yarn dev` の目視で行う。

## Architecture

### ビルドパイプライン

`vite.config.ts` で3つのプラグインを連携:
1. **honox()** - HonoX のファイルベースルーティング（`app/routes/` 配下がそのままURL）
2. **ssg({ entry })** - `app/server.ts` をエントリに静的サイト生成
3. **mdx()** - MDX を `hono/jsx` で処理。`remark-frontmatter` + `remark-mdx-frontmatter` で frontmatter を `export const frontmatter` に変換

`app/routes/recipes/{slug}/index.mdx` → `/recipes/{slug}` → ビルド後 `dist/recipes/{slug}.html`。

### レンダラーの二層構造

- `app/routes/_renderer.tsx` - ルートレイアウト。HTML shell、`<head>`（OGP/Twitter Card メタタグ）、ヘッダー、フッター、ダークモード切り替え
- `app/routes/recipes/_renderer.tsx` - レシピ専用レイアウト。frontmatter からタイトル・日付・メタ情報・ヒーロー画像・タグ・Xシェアボタンを自動レンダリング。`<Layout>` に `description` と絶対URL化した `image` を詰め直して親へ渡す

レシピMDXの frontmatter は親レイアウトの `_renderer.tsx` に `frontmatter` prop として渡され、OGP メタタグの生成に使われる。

注意点:
- サイトURL `https://recipes.qlitre.workers.dev` は両方の `_renderer.tsx` にハードコードされている。ドメイン変更時は2箇所直す
- OGP URL・Xシェア URL は `frontmatter.slug` から組み立てる。**slug はディレクトリ名と必ず一致させる**（ズレるとリンク切れになる）

### 型定義

- `app/types.ts` - `Meta` 型（frontmatter のスキーマ）。必須は `title` / `slug` / `date` / `image`、任意が `description` / `servings` / `prep_time` / `cook_time` / `tags`
- `app/global.d.ts` - Hono の `ContextRenderer` を拡張して frontmatter を受け取れるよう宣言。frontmatter に項目を足すときは `Meta` も更新する

### スタイル / クライアントJS

- CSS は `public/static/style.css` の単一ファイルのみ（CSSフレームワーク無し）。`/static/style.css` として配信
- ダークモードは `<html data-theme="dark|light">` 属性 + `[data-theme="dark"] ...` セレクタ。初期テーマは `_renderer.tsx` 内のインラインスクリプトが localStorage → OS設定の順で決定し、FOUC を避けるため `<head>` で実行する
- islands は使っていない。クライアントJSは `_renderer.tsx` の `dangerouslySetInnerHTML` によるインラインスクリプトだけ

### レシピの追加フロー

```bash
# 1. 雛形を生成（slug は必須、date 省略時は今日）
./tools/create_recipe.sh slug=recipe-name [date=YYYY-MM-DD]

# 2. 元画像を originals/ に hero.png, step1.png ... の名前で置く

# 3. 800px にリサイズして public/recipes/{slug}/ へ配置
./tools/resize.sh recipe-name            # originals/*.png すべてが対象
./tools/resize.sh recipe-name step1.png  # ファイル指定も可

# 4. app/routes/recipes/{slug}/index.mdx を編集
```

- `create_recipe.sh` は `app/routes/recipes/{slug}/index.mdx`（frontmatter テンプレート付き）と `public/recipes/{slug}/` の空 png プレースホルダを生成する。既存ディレクトリがあれば失敗する
- `resize.sh` は第1引数の slug に対応する出力ディレクトリが存在する前提（`create_recipe.sh` 実行後に使う）。`sips` と `jpegtran` を使うので macOS 前提
- MDX 内の画像参照は `/recipes/{slug}/stepN.png`。工程画像は3枚に限らず増やしてよい
- トップページ（`app/routes/index.tsx`）は `import.meta.glob` で全 `.mdx` を eager import してカード一覧を自動生成するので、一覧への手動登録は不要
- `originals/` と `dist/` は .gitignore 対象。コミットされるのは `public/recipes/` 配下のリサイズ済み画像

### デプロイ

`wrangler.jsonc` で `dist/` を assets ディレクトリに指定。SSG で生成された静的ファイルが Cloudflare Workers の assets として配信される。Worker 名は `recipes`。

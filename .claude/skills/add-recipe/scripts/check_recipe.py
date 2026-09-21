#!/usr/bin/env python3
"""レシピ1件の frontmatter と画像参照を検証する。

使い方: python3 .claude/skills/add-recipe/scripts/check_recipe.py <slug> [<slug> ...]
        （リポジトリルートで実行すること）

ビルドは frontmatter の不備や画像のリンク切れでは落ちないので、
公開前にここで機械的に潰しておく。
"""
import re
import subprocess
import sys
from pathlib import Path

REQUIRED = ["title", "slug", "date"]
SOFT = ["image"]
KNOWN = REQUIRED + SOFT + ["description", "servings", "prep_time", "cook_time", "tags"]
GENERIC_ALT = {"工程画像", "完成画像", "画像", "写真"}


def parse_frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    fm, body = {}, text[m.end():]
    for line in m.group(1).split("\n"):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        key, _, value = line.partition(":")
        fm[key.strip()] = value.strip().strip('"').strip("'").rstrip()
    return fm, body


def pixel_width(path):
    try:
        out = subprocess.run(["sips", "-g", "pixelWidth", str(path)],
                             capture_output=True, text=True, timeout=20).stdout
        m = re.search(r"pixelWidth:\s*(\d+)", out)
        return int(m.group(1)) if m else None
    except (OSError, subprocess.SubprocessError):
        return None


def check(slug, root, errors, warnings):
    mdx = (root / "app/routes/recipes" / slug / "index.mdx").relative_to(root)
    pub = (root / "public/recipes" / slug).relative_to(root)
    if not (root / mdx).exists():
        errors.append(f"{mdx} がない（./tools/create_recipe.sh slug={slug} を先に実行）")
        return

    fm, body = parse_frontmatter((root / mdx).read_text(encoding="utf-8"))
    if fm is None:
        errors.append(f"{mdx}: frontmatter (--- で囲むブロック) がない")
        return

    for key in REQUIRED:
        if not fm.get(key):
            errors.append(f"{mdx}: frontmatter に {key} がない")
    if not fm.get("image"):
        warnings.append(f"{mdx}: image が無い（ヒーロー画像なしのページになる。写真を足したら設定する）")
    for key in fm:
        if key not in KNOWN:
            warnings.append(f"{mdx}: 未知の frontmatter キー {key}（app/types.ts の Meta 型に無い）")

    if fm.get("slug") and fm["slug"] != slug:
        errors.append(f"{mdx}: slug '{fm['slug']}' がディレクトリ名 '{slug}' と違う"
                      "（OGP URL と X シェア URL が壊れる）")
    if fm.get("date") and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", fm["date"]):
        errors.append(f"{mdx}: date '{fm['date']}' が YYYY-MM-DD 形式でない")
    if fm.get("title", "").startswith("レシピタイトル"):
        errors.append(f"{mdx}: title が雛形のまま")
    if "ここに120字以内" in fm.get("description", ""):
        errors.append(f"{mdx}: description が雛形のまま")
    if len(fm.get("description", "")) > 120:
        warnings.append(f"{mdx}: description が {len(fm['description'])} 字（OGP 向けに120字以内推奨）")
    if fm.get("tags", "").find("カテゴリ1") >= 0:
        errors.append(f"{mdx}: tags が雛形のまま")
    if fm.get("image") and fm["image"] != f"/recipes/{slug}/hero.png":
        warnings.append(f"{mdx}: image が /recipes/{slug}/hero.png 以外（{fm['image']}）")

    refs = re.findall(r"!\[([^\]]*)\]\(([^)]+)\)", body)
    if fm.get("image"):
        refs.append(("(frontmatter image)", fm["image"]))
    used = set()
    for alt, path in refs:
        path = path.strip()
        if not path.startswith(f"/recipes/{slug}/"):
            errors.append(f"{mdx}: 画像パス '{path}' が /recipes/{slug}/ 始まりでない")
            continue
        target = root / "public" / path.lstrip("/")
        used.add(target.name)
        if not target.exists():
            errors.append(f"{mdx}: 参照先 {target.relative_to(root)} が存在しない")
        elif target.stat().st_size == 0:
            errors.append(f"{target.relative_to(root)} が0バイト"
                          "（create_recipe.sh のプレースホルダのまま。画像を配置するか参照を消す）")
        elif alt.strip() in GENERIC_ALT or not alt.strip():
            warnings.append(f"{mdx}: '{path}' の alt が '{alt}' と一般的すぎる（何が写っているか書く）")

    if (root / pub).exists():
        for f in sorted((root / pub).iterdir()):
            if f.name.startswith("."):
                continue
            if f.stat().st_size == 0:
                errors.append(f"{f.relative_to(root)} が0バイトのまま残っている（使わないなら削除する）")
            elif f.name not in used:
                warnings.append(f"{f.relative_to(root)} はどこからも参照されていない")
            else:
                w = pixel_width(f)
                if w and w > 800:
                    warnings.append(f"{f.relative_to(root)} が {w}px（./tools/resize.sh {slug} 未実行かも）")
    else:
        errors.append(f"{pub} がない")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    root = Path.cwd()
    if not (root / "app/routes/recipes").is_dir():
        print(f"ERROR: {root} は recipes リポジトリのルートではない", file=sys.stderr)
        return 2

    errors, warnings = [], []
    for slug in sys.argv[1:]:
        check(slug, root, errors, warnings)

    for w in warnings:
        print(f"WARN  {w}")
    for e in errors:
        print(f"ERROR {e}")
    if errors:
        print(f"\n{len(errors)} 件のエラー / {len(warnings)} 件の警告")
        return 1
    print(f"\nOK: エラーなし（警告 {len(warnings)} 件）")
    return 0


if __name__ == "__main__":
    sys.exit(main())

// app/routes/index.tsx
import type { Meta } from "../types";

export default function Top() {
  const posts = import.meta.glob<{ frontmatter: Meta }>("./recipes/**/*.mdx", {
    eager: true,
  });

  return (
    <div>
      <h2>Recipes</h2>
      <ul class="article-list">
        {Object.entries(posts).map(([id, mod]) => {
          const fm = mod.frontmatter;
          if (!fm) return null;
          const path = id
            .replace("./", "") // 先頭 ./ を削除
            .replace(/\/index\.mdx?$/, "") // /index.mdx または /index.md を削除
            .replace(/\.mdx?$/, ""); // 単体ファイル用に拡張子も保険で削除

          return (
            <li>
              <a href={`/${path}`}>{fm.title}</a>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

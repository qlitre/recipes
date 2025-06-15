// app/routes/index.tsx
import type { Meta } from "../types";

export default function Top() {
  const posts = import.meta.glob<{ frontmatter: Meta }>("./recipes/**/*.mdx", {
    eager: true,
  });

  return (
    <div class="wrapper">
      <section class="page-header">
        <h1>レシピ一覧</h1>
        <p class="page-description">家庭で作れる簡単レシピをご紹介</p>
      </section>
      
      <div class="recipe-grid">
        {Object.entries(posts).map(([id, mod]) => {
          const fm = mod.frontmatter;
          if (!fm) return null;
          const path = id
            .replace("./", "") // 先頭 ./ を削除
            .replace(/\/index\.mdx?$/, "") // /index.mdx または /index.md を削除
            .replace(/\.mdx?$/, ""); // 単体ファイル用に拡張子も保険で削除

          return (
            <div class="recipe-card">
              <a href={`/${path}`} class="recipe-link">
                <div class="recipe-content">
                  <h3 class="recipe-title">{fm.title}</h3>
                  {fm.description && (
                    <p class="recipe-description">{fm.description}</p>
                  )}
                  <div class="recipe-meta">
                    {fm.servings && <span class="meta-item">👥 {fm.servings}</span>}
                    {fm.cook_time && <span class="meta-item">🔥 {fm.cook_time}</span>}
                  </div>
                  {fm.tags && fm.tags.length > 0 && (
                    <div class="recipe-tags">
                      {fm.tags.slice(0, 3).map((tag) => (
                        <span key={tag} class="tag">#{tag}</span>
                      ))}
                    </div>
                  )}
                </div>
              </a>
            </div>
          );
        })}
      </div>
    </div>
  );
}

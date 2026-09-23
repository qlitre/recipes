import { jsxRenderer } from "hono/jsx-renderer";

export default jsxRenderer(({ children, Layout, frontmatter }) => {
  const { 
    title, 
    date, 
    description, 
    servings, 
    prep_time, 
    cook_time, 
    tags 
  } = frontmatter ?? {};

  // Generate description from recipe metadata if not provided
  const autoDescription = description || [
    servings && `${servings}`,
    prep_time && `準備時間${prep_time}`,
    cook_time && `調理時間${cook_time}`,
    tags && tags.length > 0 && `${tags.join('・')}`
  ].filter(Boolean).join('｜');

  // Create OGP props for Layout
  const layoutProps = {
    description: autoDescription,
    frontmatter: {
      ...frontmatter,
      // Ensure image is absolute URL for OGP
      image: frontmatter?.image ? `https://recipes.qlitre.workers.dev${frontmatter.image}` : undefined
    }
  };

  return (
    <Layout {...layoutProps}>
      <header class="post-meta">
        {title && <h1 class="post-title">{title}</h1>}
        {date && (
          <time dateTime={date} class="post-date">
            {date}
          </time>
        )}
        
        {/* Description */}
        {description && (
          <p class="recipe-description">{description}</p>
        )}
        
        {/* Hero image */}
        {frontmatter?.image && (
          <div class="hero-image">
            <img src={frontmatter.image} alt={`${title}の完成イメージ`} />
          </div>
        )}
        
        {/* Recipe metadata display */}
        <div class="recipe-meta">
          {servings && <span class="meta-item">👥 {servings}</span>}
          {prep_time && <span class="meta-item">⏱️ 準備 {prep_time}</span>}
          {cook_time && <span class="meta-item">🔥 調理 {cook_time}</span>}
        </div>
        
        {tags && tags.length > 0 && (
          <div class="recipe-tags">
            {tags.map((tag: string) => (
              <span key={tag} class="tag">#{tag}</span>
            ))}
          </div>
        )}
        
        {/* X Share Button */}
        <div class="share-buttons">
          <a 
            href={`https://twitter.com/intent/tweet?text=${encodeURIComponent(`${title} - ${description || autoDescription}`)}&url=${encodeURIComponent(`https://recipes.qlitre.workers.dev/recipes/${frontmatter?.slug}`)}`}
            target="_blank"
            rel="noopener noreferrer"
            class="x-share-btn"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
            </svg>
            Xでシェア
          </a>
        </div>
      </header>
      {children}
      <nav class="back-nav">
        <a href="/" class="back-link">← レシピ一覧に戻る</a>
      </nav>
    </Layout>
  );
});

import { jsxRenderer } from "hono/jsx-renderer";

export default jsxRenderer(({ children, title, frontmatter }) => {
  const site = "https://recipes.qlitre.workers.dev";
  const path = `/recipes/${frontmatter?.slug ?? ""}`;
  // Ensure OGP image is absolute URL
  const image = frontmatter?.image 
    ? (frontmatter.image.startsWith('http') ? frontmatter.image : `${site}${frontmatter.image}`)
    : `${site}/static/default-og.png`;
  const desc = frontmatter?.description ?? "";
  return (
    <html lang="ja">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        {/* ---- Primary ---- */}
        <title>{title ?? frontmatter?.title ?? "recipes"}</title>
        <meta name="description" content={desc} />
        {/* ---- Open Graph ---- */}
        <meta property="og:type" content="article" />
        <meta property="og:url" content={`${site}${path}`} />
        <meta property="og:title" content={title ?? frontmatter?.title ?? "recipes"} />
        <meta property="og:description" content={desc} />
        <meta property="og:image" content={image} />

        {/* ---- Twitter ---- */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:url" content={`${site}${path}`} />
        <meta name="twitter:title" content={title ?? frontmatter?.title ?? "recipes"} />
        <meta name="twitter:description" content={desc} />
        <meta name="twitter:image" content={image} />

        <link rel="stylesheet" href="/static/style.css" />
      </head>
      <body>
        <header class="header">
          <h1>
            <a href="/">recipes</a>
          </h1>
        </header>
        <main>
          <article>{children}</article>
        </main>
        <footer>
          <p>&copy; 2025 qlitre.</p>
        </footer>
      </body>
    </html>
  );
});

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

        <link rel="icon" type="image/x-icon" href="/favicon.ico" />
        <link rel="stylesheet" href="/static/style.css" />
        <script dangerouslySetInnerHTML={{
          __html: `
            (function() {
              const savedTheme = localStorage.getItem('theme');
              const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
              const theme = savedTheme || systemTheme;
              document.documentElement.setAttribute('data-theme', theme);
            })();
          `
        }} />
      </head>
      <body>
        <header class="header">
          <div class="header-content">
            <h1>
              <a href="/">recipes</a>
            </h1>
            <button id="theme-toggle" class="theme-toggle" aria-label="テーマ切り替え">
              <span class="theme-icon light-icon">☀️</span>
              <span class="theme-icon dark-icon">🌙</span>
            </button>
          </div>
        </header>
        <main>
          <article>{children}</article>
        </main>
        <footer>
          <p>&copy; 2025 qlitre.</p>
        </footer>
        <script dangerouslySetInnerHTML={{
          __html: `
            document.addEventListener('DOMContentLoaded', function() {
              const themeToggle = document.getElementById('theme-toggle');
              const html = document.documentElement;
              
              function updateTheme(theme) {
                html.setAttribute('data-theme', theme);
                localStorage.setItem('theme', theme);
              }
              
              themeToggle.addEventListener('click', function() {
                const currentTheme = html.getAttribute('data-theme');
                const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
                updateTheme(newTheme);
              });
            });
          `
        }} />
      </body>
    </html>
  );
});

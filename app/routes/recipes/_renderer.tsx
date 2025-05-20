import { jsxRenderer } from "hono/jsx-renderer";

export default jsxRenderer(({ children, Layout, frontmatter }) => {
  const { title, date, description } = frontmatter ?? {};

  return (
    <Layout description={description}>
      <header class="post-meta">
        {title && <h1 class="post-title">{title}</h1>}
        {date && (
          <time dateTime={date} class="post-date">
            {date}
          </time>
        )}
      </header>
      {children}
    </Layout>
  );
});

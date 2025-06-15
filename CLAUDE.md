# CLAUDE.md
日本語で回答してください
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Japanese recipe management application built with HonoX and deployed to Cloudflare Workers. The site displays cooking recipes (particularly low-temperature cooking techniques) with structured markdown content and images.

## Common Commands

- `yarn dev` - Start development server
- `yarn build` - Build for production
- `yarn preview` - Preview build locally using wrangler
- `yarn deploy` - Build and deploy to Cloudflare Workers

## Architecture

### Framework Stack
- **HonoX**: Full-stack framework built on Hono
- **Cloudflare Workers**: Deployment target with edge computing
- **MDX**: Markdown with JSX for recipe content
- **Vite**: Build tool with SSG (Static Site Generation)

### Project Structure
- `app/routes/` - File-based routing with HonoX
  - `recipes/{slug}/index.mdx` - Individual recipe pages
  - `_renderer.tsx` - Layout and SEO metadata handling
- `public/recipes/{slug}/` - Recipe images (hero.png, step*.png)
- `tools/` - Utility scripts for recipe creation and image processing

### Recipe Content Model
Each recipe is a standalone MDX file with frontmatter containing:
- `title`, `slug`, `date`, `description` (required)
- `image` - Hero image path
- `servings`, `prep_time`, `cook_time` - Recipe metadata
- `tags` - Categories for filtering

### Recipe Creation Workflow
Use `./tools/create_recipe.sh slug=recipe-name [date=YYYY-MM-DD]` to scaffold new recipes with proper directory structure and frontmatter template.

### SEO and Social Sharing
The `_renderer.tsx` handles Open Graph and Twitter Card metadata automatically from recipe frontmatter, with fallbacks for missing data.
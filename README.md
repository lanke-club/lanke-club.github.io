# 烂柯游艺社 lanke.fun

The club website, hosted for free on GitHub Pages (Jekyll). Pushing to `main` publishes it in about a minute.

## Editing

You can edit any file right on github.com (pencil icon → "Commit changes"); no local setup needed.

| What | Where |
|---|---|
| Top menu | `_data/menu.yml` |
| Homepage | `index.html` |
| Header / footer / contact email | `_layouts/default.html`, `_config.yml` |
| Colors and fonts | `assets/style.css` |
| A normal page (e.g. 通用角色) | `<page-name>/index.html` |
| Match reports / news | `_posts/YYYY-MM-DD-<anything>.html` |
| Images and PDFs | `wp-content/uploads/…` (kept at the old WordPress paths so old links still work) |

### Add a match report

Create `_posts/2026-11-02-round1.html`:

```html
---
title: 第一轮（11月1日）赛报
categories: [league-reports]
permalink: /第一轮（11月1日）赛报/
---
<p>…content…</p>
```

Use `categories: [yuanyue2]` for 圆月大会 posts and `[lanke-news]` for news. Each post shows up automatically on its listing page (联赛战报 / 第二届圆月大会 / 活动).

### Add a page

Create `my-page/index.html` with a `title:` front matter block like the one above, and link to it from `_data/menu.yml` if it belongs in the menu.

## Preview locally (optional)

```sh
gem install jekyll
jekyll serve   # then open http://localhost:4000
```

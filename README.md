# 烂柯游艺社 lanke.fun

The club website, hosted for free on GitHub Pages. It is a static copy of the old WordPress site (Astra theme + Elementor): the original HTML, CSS, JS, images and PDFs, at the same URLs. Pushing to `main` publishes it in about a minute. `.nojekyll` tells GitHub to serve the files as-is.

Removed from the WordPress version because they need a server: login/register/member pages (now redirect to the homepage), the search box, comment forms, and Google Analytics. Video blocks get a small inline script so the YouTube players actually load (they were broken on the old site).

## Layout

| What | Where |
|---|---|
| Homepage | `index.html` |
| A page or post | `<url path>/index.html`, e.g. `general-characters/index.html`, `第一轮（4月30日）赛报/index.html` |
| Report archive | `category/league-reports/` (+ `page/2..4/`) |
| Images and PDFs | `wp-content/uploads/…` |
| Theme / Elementor CSS and JS | `wp-content/themes/`, `wp-content/plugins/`, `wp-content/uploads/elementor/css/`, `wp-includes/` |

## Editing

- **Text on a page:** open its `index.html` (on github.com: pencil icon → "Commit changes") and edit the text inside the page body.
- **The menu, header or footer** is repeated in every page, so change it with a find-and-replace across all `index.html` files.
- **A new page or report:** copy an existing page's folder (e.g. a 赛报 folder), rename it, and replace the title and content.

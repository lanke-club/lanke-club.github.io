# 烂柯游艺社 · lanke.fun

The club's website. It is a [Jekyll](https://jekyllrb.com) site: content lives in plain text
files (YAML data, HTML/Markdown pages), and a build turns it into the website. Pushing to
`main` rebuilds and publishes it automatically (GitHub Actions → GitHub Pages, ~1 minute).

The look is the club's original WordPress theme (Astra + Elementor), kept pixel-for-pixel:
their CSS/JS live untouched in `assets/vendor/`, and small templates in `_includes/` produce
the same page structure from clean content.

You can edit everything on github.com (open a file → pencil icon → "Commit changes").

---

## Where things are

| What | File(s) |
|---|---|
| Menu | `_data/menu.yml` |
| Home page text, QR codes, poem | `index.html` (the part between the `---` lines) |
| Match reports (赛报) and news | `_posts/` — one file per post |
| 角色全册: every role | `_data/roles.yml` (+ icons in `assets/img/roles/`) |
| 角色全册: chapters & 版型 | `_data/rulebook/general.yml`, `classic.yml`, `extension.yml`, `third_party.yml`, `original.yml` |
| 角色全册 header text, chapter order | `_data/rulebook_info.yml` |
| 角色全册基本原则 | `pages/角色全册基本原则.html` |
| 角色图标 gallery | `_data/icons.yml` |
| Other pages | `pages/` — one file per page (e.g. `pages/烂柯社区.html`); the URL is its `permalink` |
| Redirects from old WordPress URLs | `redirects/` |
| Images and PDFs | `wp-content/uploads/…` (old WordPress paths, so old links keep working) |
| Site name, email, archive settings | `_config.yml` |
| Site-specific styles | `assets/css/site.css` |

`目录` (the 角色全册 table of contents) and the `/category/…` archive pages are generated —
there is nothing to edit; they update when you add roles, 版型 or posts.

---

## Common tasks

### Add a match report (赛报)

Create `_posts/2026-11-08-第一轮（11月7日）赛报.html` (date first, then any name):

```yaml
---
layout: report
title: 第一轮（11月7日）赛报
date: 2026-11-08 20:00:00
permalink: /第一轮（11月7日）赛报/
categories: [league-reports]
honors: |
  **功勋**：
  青铜-先知先觉-某某
  青铜-全知全能-某某

  白银-神目如电-某某
awards: |
  **MVP**：
  第一局
  女巫某某

  **鼓励奖**：
  第二局
  梦魇某某
videos:
  - url: https://youtu.be/XXXXXXXXXXX
    cover: /wp-content/uploads/2021/03/wolf-963081-scaled.jpg   # optional
---
```

`honors` is the left column, `awards` the right one. Leave out `videos` if there is none, or
add `notes:` for text between the dividers. The post appears automatically in
联赛赛报 (`/category/league-reports/`) and in the previous/next links.

### Add a news post

Same as above but with `layout: post`, `categories: [lanke-news]`, and the text written
below the closing `---` — HTML in a `.html` file, or Markdown if you name the file `.md`.

### Change the menu

Edit `_data/menu.yml`. Each item has `title` and `url`; nest items under `children:` for a
dropdown. Both the desktop and mobile menus come from this file.

### Add a role / 版型 to 角色全册

1. Add the role to `_data/roles.yml`:
   ```yaml
   新角色:
     anchor: new-role                          # used in links: [新角色](#new-role)
     icon: /assets/img/roles/新角色.png          # a 128×128 PNG
     quote: 台词写在这里。
     rules: |
       **新角色** · 神
       【技能】技能描述……

       注：……
   ```
2. Add the 版型 to the right chapter in `_data/rulebook/`:
   ```yaml
   - id: template77
     number: 77
     name: 新角色 - 预女猎守
     lineup: 1 [新角色](#new-role)，3 [普狼](#werewolf)；4 [村民](#villager)，1 [预言家](#seer)
     order: 新角色，普狼，预言家
     blocks:
       - role: 新角色
   ```
   It shows up on the chapter page and in 目录. `blocks` can also contain `text:` entries
   (and any widget listed under "Custom page layouts" below).

### Add an icon to 角色图标

Upload the full-size image plus a 150×150 copy named `<name>-150x150.png` into
`wp-content/uploads/<year>/<month>/`, then add to `_data/icons.yml`:
```yaml
- image: /wp-content/uploads/2026/11/新角色.png
  caption: 新角色
```

### Add a normal page

Create `pages/my-page.html`:
```yaml
---
title: 页面标题
permalink: /my-page/
---
<p>Content in HTML…</p>
```
(or `pages/my-page.md` with Markdown). The `permalink` is the page's URL. Link it from
`_data/menu.yml` if needed.

---

## Text format (lk-text)

Fields such as `honors`, `rules`, `quote` and `text:` use a tiny format:

| Write | Shows |
|---|---|
| a blank line | new paragraph |
| a line break | line break |
| `**bold**`, `*italic*` | **bold**, *italic* |
| `[text](https://…)` | link |
| `[普狼](#werewolf)` | link to that role/版型 on whatever 角色全册 page has it |
| `~ text` at the start of a line | greyed-out line (e.g. abilities a role inherits) |
| `\` alone on a line | an empty line |
| `\*` `\[` `\]` `\\` | a literal `*` `[` `]` `\` |

A few old entries use `rules_html:` / `html:` / `honors_html:` instead — those are the
original HTML, kept where the old formatting can't be expressed in lk-text without changing
how it looks (e.g. a word coloured differently mid-sentence). You can edit them as HTML, or
rewrite them in lk-text with `rules:` / `text:` / `honors:` if a tiny visual change is fine.

---

## Custom page layouts

Pages with `layout: builder` (or posts with `layout: builder-post`) can be laid out in the
front matter with `sections:` — rows, optional two columns, and widgets:

```yaml
sections:
  - widgets:
      - heading: 标题
        class: lk-center
      - text: |
          段落一

          段落二
      - divider: true
  - columns:
      - span: 50
        widgets:
          - image: /wp-content/uploads/2021/03/logo.png
      - span: 50
        widgets:
          - video: https://youtu.be/XXXXXXXXXXX
```

Widgets: `text` (lk-text), `html`, `heading` (+`tag: h2|h3`), `image`, `video` (+`cover`),
`divider`, `anchor`, and `columns` (a nested row). Helper classes for `class:`:
`lk-center` (centred), `lk-ink` (black text).

---

## How it's built

- `_layouts/` — page types: `base` (header/footer), `page`, `builder`, `post`, `report`,
  `archive`, `rulebook`, `catalog`, `gallery`, `home`, …
- `_includes/el/` — the page-builder pieces (section, column, text, image, video, divider…)
- `_plugins/` — lk-text, image helpers (responsive `srcset` for WordPress uploads), and the
  category archive generator. Because of these, the site is built by
  `.github/workflows/pages.yml`, not GitHub's default Jekyll.
- `assets/vendor/` — third-party theme files (Astra, Elementor, jQuery). Don't edit.
- `_includes/inline-css/` — the theme's inline styles, per page type. Don't edit.

### Preview locally (optional)

```sh
bundle install
bundle exec jekyll serve     # then open http://localhost:4000
```

### Checking that a change didn't alter the look

`tools/visual-diff.py` screenshots every page of two versions (e.g. the live site and your
local preview) at desktop and phone width and reports any pixel that differs. Instructions
are at the top of the file. It was used to verify this site against the original WordPress
version: every page matched except intentional fixes.

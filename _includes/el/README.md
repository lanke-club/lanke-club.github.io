Page-builder components. Each reproduces the markup of the matching Elementor widget so the
theme CSS in assets/vendor/elementor applies unchanged. Layouts compose them; content files
should not need to call them directly.

  section.html  content, inner (bool), class        → <section> row
  column.html   content, span (100|50), inner, width (desktop % override)
  heading.html  text, tag (h2|h3), class
  text.html     html, class                         → text block (class: lk-center, lk-ink…)
  image.html    src, alt, title, class
  video.html    url, cover (image url, optional)
  divider.html                                      → line with the paw icon
  anchor.html   id                                  → jump target for #links

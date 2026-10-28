"""Screenshot every page of two versions of the site and compare them pixel by pixel.

Use it to check that a change (a refactor, a theme tweak) didn't alter how pages look:

    pip install playwright pillow numpy        # uses your installed Google Chrome
    bundle exec jekyll build                   # pages to check are read from _site/
    bundle exec jekyll serve --port 4001 &     # your version
    python tools/visual-diff.py https://lanke.fun http://127.0.0.1:4001 /tmp/vdiff

It compares each page at desktop (1440px) and phone (390px) width, prints the pages that
differ, and saves base/new/diff images (differences in red) to the output folder.
Embedded videos and sheets are hidden (they are external), and every page is scrolled
through first so lazy images load.
"""
import asyncio
import os
import sys
import urllib.parse

import numpy as np
from PIL import Image
from playwright.async_api import async_playwright

VIEWPORTS = {'desktop': (1440, 900), 'mobile': (390, 844)}
FREEZE = ('*,*::before,*::after{animation:none!important;transition:none!important;caret-color:transparent!important}'
          'iframe{visibility:hidden!important}')


def site_paths(site_dir='_site'):
    out = []
    for root, _, files in os.walk(site_dir):
        if 'index.html' not in files or '/assets' in root or '/wp-' in root:
            continue
        if 'http-equiv="refresh"' in open(os.path.join(root, 'index.html'), encoding='utf-8').read(400):
            continue  # redirects
        rel = os.path.relpath(root, site_dir)
        out.append('/' if rel == '.' else f'/{rel}/')
    return sorted(out)


async def shoot(page, url, path):
    await page.goto(url, wait_until='networkidle')
    await page.add_style_tag(content=FREEZE)
    await page.evaluate('async () => { for (let y = 0; y < document.body.scrollHeight; y += 600) '
                        '{ window.scrollTo(0, y); await new Promise(r => setTimeout(r, 30)); } window.scrollTo(0, 0); }')
    await page.wait_for_load_state('networkidle')
    await page.evaluate('Promise.all([...document.images].filter(i => i.complete).map(i => i.decode().catch(() => {})))')
    await page.wait_for_timeout(300)
    await page.screenshot(path=path, full_page=True)


def compare(a, b, diff_path):
    ia, ib = Image.open(a).convert('RGB'), Image.open(b).convert('RGB')
    if ia.size != ib.size:
        return f'page size {ia.size} vs {ib.size}'
    x, y = np.asarray(ia, dtype=np.int16), np.asarray(ib, dtype=np.int16)
    delta = np.abs(x - y).max(axis=2)
    if not delta.any():
        return None
    out = (y * 0.3).astype(np.uint8)
    out[delta > 0] = [255, 0, 0]
    Image.fromarray(out).save(diff_path)
    ys, xs = np.nonzero(delta)
    return f'{len(ys)} px differ (max {delta.max()}/255) in x{xs.min()}-{xs.max()} y{ys.min()}-{ys.max()}'


async def main():
    base, new, out = sys.argv[1].rstrip('/'), sys.argv[2].rstrip('/'), sys.argv[3]
    paths = sys.argv[4:] or site_paths()
    os.makedirs(out, exist_ok=True)
    differ = 0
    async with async_playwright() as p:
        browser = await p.chromium.launch(channel='chrome')
        for vname, (w, h) in VIEWPORTS.items():
            ctx = await browser.new_context(viewport={'width': w, 'height': h}, is_mobile=vname == 'mobile',
                                            has_touch=vname == 'mobile')
            page = await ctx.new_page()
            for path in paths:
                slug = (path.strip('/') or 'home').replace('/', '__') + '.' + vname
                a, b = f'{out}/{slug}.base.png', f'{out}/{slug}.new.png'
                q = urllib.parse.quote(path)
                result = None
                for _ in range(2):  # re-shoot once to rule out load-timing flakes
                    await shoot(page, base + q, a)
                    await shoot(page, new + q, b)
                    result = compare(a, b, f'{out}/{slug}.diff.png')
                    if not result:
                        break
                if result:
                    differ += 1
                    print(f'DIFF {vname:7} {path}  {result}', flush=True)
                else:
                    os.remove(a)
                    os.remove(b)
            await ctx.close()
        await browser.close()
    print(f'{len(paths)} pages x {len(VIEWPORTS)} widths: {differ} differ')


asyncio.run(main())

# FOMO-morning · daily build prompt

You are producing today's issue of **FOMO-morning**, a daily typographic
magazine shipped every morning at 08:00 Zürich. You are running inside
`/Users/vadim/work/fomo` (local) or a fresh clone of `vxsx/fomo` (remote).

## Step 1 — Establish today's date

Use the system date. Convert to `YYYY-MM-DD` in Europe/Zurich. Store it as
`$ISSUE_DATE`. The issue number is the count of files in `magazines/` + 1
(i.e., if `magazines/` has 12 files before you write, today is issue 013).

## Step 2 — Fetch six sources

Fetch the homepages of all six sources in parallel with `WebFetch`:

- https://every.to/
- https://www.deeplearning.ai/the-batch/
- https://www.therundown.ai/
- https://thezvi.substack.com/archive
- https://jack-clark.net/
- https://www.jeffbullas.com/jabs/

For each, extract the latest ~6–8 articles: title, author (if visible),
1–2 sentence dek, URL, topic tags.

If a source fails, try once more with its `/archive` or RSS equivalent. If
still failing, note the absence in the colophon — don't fabricate content.

## Step 3 — Pick ten articles

**Rubric (in priority order):**

1. AI tools you could adopt this week
2. Creative software / generative media
3. Dev tools & agentic coding
4. Privacy & security (only when signal is high)
5. Science & research with a practical kernel
6. Anything immediately actionable for a senior engineer / founder

Hard rules:

- Skip pure hype/marketing.
- Skip opinion-only pieces unless they sharply change how you'd act tomorrow.
- Max 3 picks from any single source. Aim for ≥4 sources represented.
- If two picks overlap heavily, keep the better-written one.

## Step 4 — Render the magazine

Write **one** self-contained HTML file to `magazines/$ISSUE_DATE.html`. Use
`magazines/2026-04-19.html` as the structural reference — same cover, same
ten-spread progression, same colophon.

**Typography (unchanged):**

- `Fraunces` + `Inter` + `JetBrains Mono` from Google Fonts.
- Minimum body size 18px. Display headlines 64px+ on desktop.
- No small type anywhere. If you're tempted, rewrite shorter.

**Mobile / wrapping rules — non-negotiable:**

These failed in issue 001 and must be baked into every issue. Copy the CSS
baseline from `magazines/2026-04-19.html` unchanged, specifically:

- `html, body { overflow-x: hidden; }` — kill horizontal scroll.
- `h1, h2, h3, h4 { overflow-wrap: break-word; hyphens: auto; }` —
  so long words wrap instead of clipping off the edge.
- The `.folio` and `.cover .kicker` flex rows **must** use
  `flex-wrap: wrap; gap: 8px ...` — otherwise phrases like "FOMO · MORNING"
  and "19 APR 2026" smash together with no space.
- No `&nbsp;` inside display headlines unless you are 100% sure the paired
  words fit on one mobile line. Prefer plain spaces.
- Headline sizes on mobile (<=800px) use `vw` units, not `clamp()` minimums
  above ~48px. If `clamp(72px, 12vw, 220px)` has a 72px floor, a 360px
  viewport will clip. Use `font-size: 12-13vw` inside the mobile media
  query.
- Headlines wrap → bump `line-height` to ≥1.02 on mobile. Desktop 0.85 is
  fine, but don't assume headlines stay single-line.
- Disable drop caps on mobile (`float: none; font-size: inherit;`) — they
  collapse narrow columns into 2-words-per-line.
- Set `max-width: 100%` on ledes, body copy, and abstracts inside the
  mobile media query. `ch`-based caps overflow on phones.
- Collapse `.columns { column-count: N }` to 1 column on mobile.
- The `.folio` must go `position: static; margin-bottom: 16px` on mobile
  so it doesn't overlap the headline.
- Two-column grids collapse to 1; 5-column grids to 2 (and to 1 under
  420px).

**Ten spread themes — rotate freely so no two issues look identical.**
You must use a *different* colour and layout for every story. Pick 10 from:

1. **Hero / editorial cream** — big serif display, oxblood accent
2. **Warm orange** — two-column, pull-quote
3. **Big stats / yellow** — giant numeric glyph + 3-up stat dl
4. **Terminal** — green-on-black, scanlines, ASCII
5. **Academic journal** — cream + navy, sidebar + two-column body
6. **Midnight** — deep navy with gradient text, big-number callout
7. **Dark report / classified** — crimson on near-black, mini bar chart
8. **Hot pink** — four bullets, numbered italic
9. **Neon / cyberpunk** — purple+teal gradient, terminal card
10. **Teal grid** — 2×5 grid of cards with numbered italic corners
11. **Risograph duotone** — cyan/magenta overprint
12. **Newsprint** — cream + black, three narrow columns
13. **Blueprint** — pale grid background, monospace annotation
14. **Pastel pink** — soft gradients, handwritten-feel italic
15. **Neo-brutalist** — chunky black borders, yellow/white
16. **Concrete** — warm grey, asymmetric layout

Each spread must have: folio (NN / 10 + source), tag, headline, lede,
secondary visual element (pull quote, stats, terminal, graph, grid, etc.),
and a `.read-on` button pointing at the article URL.

**Cover spread** lists the ten stories with a dotted TOC.
**Colophon spread** lists sources, rubric, and the issue number.

## Step 5 — Rebuild the index

Regenerate `index.html` so it:

1. Redirects to today's latest issue after 2s (meta refresh)
2. Shows a list of all past issues newest-first, linking to `magazines/*.html`

Read `magazines/` to build the list.

## Step 6 — Commit and push

```bash
cd /path/to/fomo
git add -A
git commit -m "issue $ISSUE_NUMBER — $ISSUE_DATE"
git push origin main
```

GitHub Pages publishes on push (30–90s). The URL for today is
`https://vadim.sikora.name/fomo/magazines/$ISSUE_DATE.html`.

## Step 7 — Notify Telegram

Run `./scripts/notify.sh "$ISSUE_DATE"`. It reads `.env`, posts the URL to
the configured chat, and exits non-zero on failure. Surface the error in
your final message if it fails — don't retry blindly.

## Step 8 — Final summary

Report back in ≤80 words: issue number, date, the 10 story titles, and the
public URL.

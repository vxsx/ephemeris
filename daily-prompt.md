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

GitHub Pages publishes on push. The URL for today is
`https://vxsx.github.io/fomo/magazines/$ISSUE_DATE.html`.

## Step 7 — Notify Telegram

Run `./scripts/notify.sh "$ISSUE_DATE"`. It reads `.env`, posts the URL to
the configured chat, and exits non-zero on failure. Surface the error in
your final message if it fails — don't retry blindly.

## Step 8 — Final summary

Report back in ≤80 words: issue number, date, the 10 story titles, and the
public URL.

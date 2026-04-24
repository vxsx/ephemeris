# FOMO-morning · daily build prompt

You are producing today's issue of **FOMO-morning**, a daily typographic
magazine shipped every morning at 08:00 Zürich. You are running inside
`/Users/vadim/work/fomo` (local) or a fresh clone of `vxsx/fomo` (remote).

## Step 1 — Establish today's date

Use the system date. Convert to `YYYY-MM-DD` in Europe/Zurich. Store it as
`$ISSUE_DATE`. The issue number is the count of files in `magazines/` + 1
(i.e., if `magazines/` has 12 files before you write, today is issue 013).

## Step 2 — Fetch all sources

Fetch these homepages in parallel with `WebFetch`. Extract the latest
~5–8 items per source: title, author (if visible), 1–2 sentence dek,
URL, topic tags.

**Newsletters / curation:**

- https://www.deeplearning.ai/the-batch/
- https://thezvi.substack.com/archive
- https://jack-clark.net/
- https://www.jeffbullas.com/jabs/

**Model labs:**

- https://openai.com/news/rss.xml  ← use this RSS URL; the HTML pages block scrapers
- https://www.anthropic.com/engineering
- https://www.anthropic.com/news

**Engineering blogs:**

- https://github.blog/category/engineering/
- https://sentry.engineering/feed.xml  ← RSS, not sentry.io/blog which is marketing + Cloudflare-blocked
- https://vercel.com/blog
- https://posthog.com/rss.xml  ← RSS; the HTML page is JS-rendered
- https://blog.cloudflare.com/
- https://fly.io/blog/
- https://nextjs.org/feed.xml  ← RSS for Next.js blog

**Telegram channels** (fetch the public `t.me/s/` preview):

- https://t.me/s/seeallochnaya
- https://t.me/s/TochkiNadAI
- https://t.me/s/denissexy
- https://t.me/s/rvnikita_blog
- https://t.me/s/ProductsAndStartups

Extract the last ~5–8 posts per channel. Short posts are expected — pick
the ones that link out to a primary source or contain a concrete, actionable
insight (tool release, benchmark, case study, playbook). Skip pure meme /
reaction posts. **Attribute in the magazine as "via @channelname"**, and
use the primary source URL where one is linked.

If a source returns empty / 403 / a JS-rendered shell with no post content,
try (in order): `/rss.xml`, `/feed.xml`, `/rss/`, `/feed/`, `/archive`. Many
marketing-skinned blogs still expose a real feed. If still failing after
that, note the absence in the colophon — don't fabricate content.

For model-lab announcements (OpenAI/Anthropic), count them for the rubric
only if the post describes something useful — a new API primitive, a SDK
update, a technical deep-dive, a benchmark, a case study, a behavior
change. **Skip pure product-marketing** ("announcing our partnership
with X", leadership shuffles, funding rounds).

## Step 3 — Pick 5 to 10 articles

Aim for ten; ship fewer if the day is thin. **Minimum 5, maximum 10.**
Do not pad with weak picks — a 6-story issue with real signal beats a
10-story issue with four fillers.

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
- **Max 2 picks from any single source.** At least 4 distinct sources
  represented on a 5–7 issue; at least 6 on an 8–10 issue.
- Engineering-blog posts (GitHub/Sentry/Vercel/PostHog) count only if they
  teach something (postmortem, architecture deep-dive, new primitive, tool
  release) — skip launch fluff / positioning posts.
- If two picks overlap heavily, keep the better-written one.
- If a Telegram channel post links out to a primary source, prefer the
  primary source's URL in the magazine (but credit the channel as "via").

**No reprints.** Before finalizing, enumerate every URL already
published across prior issues — one-liner:

```bash
grep -hoE 'class="read-on"[^>]*href="[^"]+"' magazines/*.html \
  | grep -oE 'href="[^"]+"' | sort -u > /tmp/published-urls.txt
```

Any candidate whose URL appears in `/tmp/published-urls.txt` is out. Also
reject candidates that are *the same story* reported from a different
source (e.g. OpenAI's Codex announcement vs. Rundown's recap of it — one
of them was already in issue 002, both are out). "Codex for (almost)
everything" shipped in both issue 002 and 003 — that was the failure
mode.

## Step 4 — Render the magazine

Write **one** self-contained HTML file to `magazines/$ISSUE_DATE.html`.

### Start from `scaffold.html`

`scaffold.html` in the repo root is the **locked structural baseline**.
Copy it. Don't re-derive the skeleton from scratch and don't crib from
prior issues — their layouts were free-form and introduced overlap
bugs in every issue 001–005.

The scaffold enforces: folio → main → cta as a 3-row CSS Grid so
nothing can overlap. Decorative elements live in a `.decor` layer at
`z-index: 0` behind content. `safe center` alignment, `overflow-wrap`,
descender space, and `--flip` hover defaults are all baked in.

### What you may change per issue

- **Palette:** `.sNN { background: …; color: … }`
- **Typography on hed/lede/tag:** font-family, weight, style, size,
  optical-size axis, italic switching
- **`.figure` content:** pull-quote, stats, terminal block, graph,
  grid — whatever the theme calls for, inside `.main` flow
- **`.decor` content:** pseudo-elements, positioned children, patterns,
  ghost type — anything, because it's behind content
- **Per-spread `--flip`** on `.read-on` (see hover rule)
- **Cover masthead treatment** and **colophon wrap copy**

### What you must NOT change

- `grid-template-rows`, `padding`, or `display` on `.spread`
- `position` on `.folio`, `.main`, `.tag`, `.hed`, `.lede`, `.figure`,
  `.cta`, `.read-on` — they stay in the grid / in-flow
- The `.decor` layer contract (`position: absolute; inset: 0; z-index: 0;
  pointer-events: none`)
- Global `html, body { overflow-x: hidden }` and the `h1–h4` wrap rules
- The mobile `@media (max-width: 800px)` block (you can ADD to it, but
  the existing rules stay)

### Variety comes from surface, not structure

Issues 001 and 002 were identical because layouts were copied. Issues
003–005 had different layouts but every one shipped with an overlap
bug because each layout was reinvented. The sweet spot: structure
stable, surface changes. Think of it as a magazine with a consistent
grid and a guest art director per issue — same bones, different skin.

**Typography (unchanged):**

- `Fraunces` + `Inter` + `JetBrains Mono` from Google Fonts.
- Minimum body size 18px. Display headlines 64px+ on desktop.
- No small type anywhere. If you're tempted, rewrite shorter.

### Pitfalls the scaffold can't prevent

The scaffold handles overflow-wrap, safe-center alignment, flex-wrap on
folios, descender padding on `.hed`, mobile clamps, and `--flip`
defaults. The things below are about content choices or new CSS you
write — the scaffold can't enforce them for you:

1. **No `&nbsp;` inside display headlines.** Forced non-breaks clip on
   narrow viewports. Plain spaces. If a phrase must stay together, it's
   too long for a headline — rewrite.
2. **Reset `letter-spacing: normal` on spans nested inside display
   numerals.** A parent's `letter-spacing: -0.06em` at 360px inherits
   as **-22px** (absolute pixels) into a 79px child → letters crush.
   Template:
   ```css
   .sNN .num .unit {
     font-family: var(--sans); font-style: normal; font-weight: 700;
     font-size: 0.22em;
     letter-spacing: normal;
     margin-left: 0.5em;          /* italic swashes need real space */
   }
   ```
3. **If you add a multi-column block** (`column-count: N`), override it
   to `column-count: 1` in the mobile media query.
4. **Decorative positioned content goes in `.decor`, never on
   `::before` / `::after` of the spread or of content elements.** The
   `.decor` layer is `position: absolute; inset: 0; z-index: 0;
   pointer-events: none` and lives *behind* content via isolation —
   overlap becomes impossible. Every time issues 003–005 had overlap,
   the cause was decoration outside this layer.
5. **Don't re-add drop caps.** `::first-letter` float collapses narrow
   columns into 2-words-per-line on mobile, and no CSS can save it.
6. **Corner decor inside `.decor` still collides with the folio on
   mobile.** Anything pinned to `top: <small>; left: <small>` lives at
   the same coords as the folio after mobile padding shrinks. Either
   drop it below `top: clamp(72px, 9vw, 120px)`, or `display: none` it
   in the mobile media query. Issue 006 s05 had a 28×28 L-corner at
   (24, 24) stepping on the folio.
7. **If a `.figure` uses CSS Grid with one child that spans all
   columns** (`grid-column: 1 / -1`), other siblings will be
   auto-placed into *any* remaining cell — including the wrong column.
   Either set `grid-auto-flow: dense` and explicit `grid-column` on
   every child, or collapse the grid to a single column on mobile
   (`grid-template-columns: 1fr`). Issue 006 s05 `.specs` auto-placed
   `.val` into a 50px column on mobile so every word broke onto its
   own line.

**Spread themes — surface treatments, not structural redesigns.** Pick
one per story. Each item below is a package of *palette + type choices
+ decorative motifs* applied on top of the scaffold's fixed grid.
"Two-column", "bar chart", "terminal card" etc. live inside `.figure`
(in-flow) or `.decor` (behind content) — never by rearranging the
spread shell. Cast themes tonally (privacy → dark report; case study
→ big stats; research → academic; creative tool → risograph;
postmortem → terminal; launch → neon).

1. **Hero / editorial cream** — big serif display, oxblood accent
2. **Warm orange** — two-column, pull-quote
3. **Big stats / yellow** — giant numeric glyph + 3-up stat dl
4. **Terminal** — green-on-black, scanlines, ASCII
5. **Academic journal** — cream + navy, sidebar + two-column body
6. **Midnight** — deep navy with gradient text, big-number callout
7. **Dark report / classified** — crimson on near-black, mini bar chart
8. **Hot pink** — four bullets, numbered italic
9. **Neon / cyberpunk** — purple + teal gradient, terminal card
10. **Teal grid** — 2×5 grid of cards with numbered italic corners
11. **Risograph duotone** — cyan/magenta overprint, slight registration offset
12. **Newsprint** — cream + black, three narrow columns, serif small caps
13. **Blueprint** — pale grid background, monospace annotation, crop marks
14. **Pastel rose** — soft gradients, handwritten-feel italic, generous air
15. **Neo-brutalist** — chunky black borders, yellow/white, no curves
16. **Concrete** — warm grey, asymmetric layout, giant punctuation
17. **Film still** — letterboxed dark, cinematic sans all-caps
18. **Spreadsheet** — monospace tabular, subdued greys, gridlines
19. **Postcard** — horizontal split, two-tone, decorative border, stamp motif
20. **Museum placard** — ivory + dark olive, classical proportions, centered
21. **Memo / airgram** — typewriter, margin rules, CC / RE: header

**Cover treatments — pick one, rotate.** The masthead "FOMO / morning."
does **not** have to be the hero every day.

A. **Masthead lockup** — big serif wordmark + dotted TOC (issue 001 default)
B. **Pull-quote cover** — one giant italic quote from today's best story,
   masthead demoted to a corner line
C. **Dossier grid** — N numbered cells (one per story), each a headline
   fragment + source, no single hero element
D. **Manifesto** — one paragraph in 48px+ serif that names today's theme
   ("Today's issue is about agents learning to read")
E. **Date-hero** — giant typographic date ("MON 20 · APR 26") as the visual;
   TOC beneath
F. **Editor's note** — 3-sentence italic intro in the editor's voice,
   smaller TOC
G. **Single-word mood** — one display word ("LEAKS", "QUIET", "AGENTS")
   lifted from today's stories, TOC below
H. **Source map** — horizontal row of the 18 source names with dots marking
   which contributed today, then TOC

Each spread must have: folio (NN / total + source, where total is today's
story count — so "04 / 07" on a 7-story issue), tag, headline, lede,
secondary visual element (pull quote, stats, terminal, graph, grid, etc.),
and a `.read-on` button pointing at the article URL.

**Colophon spread** lists sources, rubric, and the issue number — can and
should vary visually (dark on one issue, newsprint on another).
**Do not name the fonts, say "hand-laid", or narrate how the issue was
made.** That copy reads as self-congratulatory. Keep it to the facts:
which sources fed today's picks, the rubric, and the issue date.

## Step 4b — Divergence check (before you write)

Read the two most recent issues in `magazines/` (excluding today's). List
the themes each used in order. Today's issue must:

- Share at most **40%** of themes with yesterday's issue (round down —
  e.g. 3/8 or 4/10).
- Share at most **60%** with the day before.
- Use a cover treatment that's different from both.
- Put repeated themes in a genuinely different slot order (don't just
  shuffle neighbours).

If your first draft fails any of these, swap themes until it passes.
This is a hard gate — if yesterday's issue looks like today's, you failed
the task regardless of how pretty either issue is.

## Step 5 — Rebuild the index

Regenerate `index.html` so it shows a list of all issues newest-first,
linking to `magazines/*.html`. **Do not add a `<meta http-equiv="refresh">`
auto-redirect** — readers should land on the archive and pick. Read
`magazines/` to build the list. Today's issue appears at the top, labelled
with its pretty date.

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

Report back in ≤80 words: issue number, date, the story titles (5–10), and the
public URL.

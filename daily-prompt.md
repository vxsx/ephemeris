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

**Locked technical baseline (copy from `magazines/2026-04-19.html` unchanged):**
the Google Fonts `<link>`, the `:root` font vars, the `@media (max-width: 800px)`
mobile rules, the `.spread` shell, the `.read-on` button, the `.folio` utility,
and the overflow-wrap rules on `h1–h4`. These took iteration — don't re-derive.

**Everything else — palette, layout, type treatment, decorative motifs,
spread order, and the cover treatment — is a fresh design decision every
day.** Think of FOMO-morning as a magazine with a guest art director on
rotation: typography and rubric stay constant, visual personality shifts
issue to issue. Issues 001 and 002 came out visually identical — that was
the failure mode.

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
- **Use `justify-content: safe center` (and `align-items: safe center`)**
  on any flex container whose children might be taller than the container.
  Plain `center` causes symmetric overflow when content exceeds the box —
  the last element (often the `.read-on` button) clips off. This hit
  issue 003's PostHog spread.
- For letterbox / masthead decorations, prefer absolute-positioned
  pseudo-elements over `grid-template-rows: Npx 1fr Npx`. The grid version
  constrains the middle track to viewport-bound space and overflows
  invisibly under `overflow: hidden`.
- **Every per-spread `.read-on` override must set `--flip` to the spread's
  background colour.** The base rule does `:hover { background: currentColor }`
  and `:hover span { color: var(--flip, #fff) }`. If the spread's text is
  *light* (cream, pastel), hover makes the bg light and the text falls
  back to white → invisible. Issue 003's PostHog CTA read white-on-cream.
  Example: `.sXX .read-on { color: #fff2d1; border-color: #fff2d1; --flip: #080808; }`.
- **Decorative lines / rules / crop marks must sit inside the spread's
  left/right padding, never in the content column.** The spread base
  padding is `clamp(24px, 6vw, 120px)`; position any `::before` rule at
  `left: clamp(16px, 3vw, 48px)` (well under 6vw) so at every viewport
  it stays to the left of content. Issue 003's memo margin rule was at
  `8vw` vs. `6vw` content padding and sliced through the text on
  desktop.
- **Decorative pseudo-elements at the top of a spread must not share the
  vertical strip with `.folio`.** The folio lives at
  `top: clamp(20px, 3vw, 40px)`. Any `::before` header / stamp / tag
  belongs below it (`top: clamp(72px, 9vw, 120px)` or further down).
  Issue 005's Cloudflare spread put a "CLASSIFICATION" pseudo-header at
  the same `top` as the folio and the two stacked on top of each other.
- **Display type with `line-height < 1` must reserve descender space.**
  Fraunces italic `p`, `g`, `y`, `j` drop well below the baseline. If
  your display element has `line-height: 0.82–0.9`, add
  `padding-bottom: 0.15em` (or equivalent margin) or bump line-height to
  ≥ 0.95 so descenders don't intrude into the next element. Issue 005's
  cover `protocols.` descender overlapped the subtitle.
- **Superscript "unit" glyphs on big italic numerals need real space.**
  Italic Fraunces digits have generous right-side swashes. When
  appending a unit (`faster`, `/day`, `×`) with `vertical-align`, use
  `margin-left: 0.4–0.6em` — `0.1em` is not enough and the word ends up
  visually behind the glyph. Or switch to `display: inline-flex` with
  an explicit `gap`.
- **Reset `letter-spacing`, `font-style`, and `font-family` on child
  spans inside display numerals.** `letter-spacing: -0.06em` on a 360px
  parent computes to ≈ -22px and **inherits as an absolute pixel value**
  into children — at a 79px child that's catastrophic crushing, letters
  literally stack on top of each other. Issue 005's "faster" unit
  rendered as `f̶a̶s̶t̶e̶r̶`. Template for unit spans:
  ```css
  .hero-num .unit {
    font-family: var(--sans);  /* break out of italic serif */
    font-style: normal;
    font-weight: 700;
    font-size: 0.22em;
    letter-spacing: normal;    /* reset the inherited px value */
    margin-left: 0.5em;        /* clear the swash */
  }
  ```

**Spread themes — pick one per story from this bench (so 5 to 10 per issue).** Each spread must use
a different colour *and* layout than the others in the same issue. Cast
themes to stories tonally (don't randomize — e.g. privacy → dark report;
case study → big stats; deep research → academic; creative tool →
risograph; launch → neon; postmortem → terminal; etc.).

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

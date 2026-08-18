# Ephemeris

A weekly editorial digest of the best writing on AI tools, creative software,
dev tools, privacy and science — delivered every **Saturday at 08:00 Zürich**
as a typographically over-the-top HTML magazine.

Daily with 3–5 picks through issue 116 (2026-08-17); weekly with 10 from
issue 117 on.

Live: https://vadim.sikora.name/ephemeris/

## Sources scanned every Saturday

**Newsletters / curation**

- [deeplearning.ai/the-batch](https://www.deeplearning.ai/the-batch/)
- [thezvi.substack.com](https://thezvi.substack.com/)
- [jack-clark.net](https://jack-clark.net/) (Import AI)
- [jeffbullas.com/jabs](https://www.jeffbullas.com/jabs/)

**Model labs**

- [openai.com/news](https://openai.com/news/) (via RSS — HTML is scraper-blocked)
- [anthropic.com/engineering](https://www.anthropic.com/engineering)
- [anthropic.com/news](https://www.anthropic.com/news)

**Engineering blogs**

- [github.blog/category/engineering](https://github.blog/category/engineering/)
- [sentry.engineering](https://sentry.engineering/) (via RSS)
- [vercel.com/blog](https://vercel.com/blog)
- [posthog.com/blog](https://posthog.com/blog) (via RSS)
- [blog.cloudflare.com](https://blog.cloudflare.com/)
- [fly.io/blog](https://fly.io/blog/)
- [nextjs.org/blog](https://nextjs.org/blog) (via RSS)

**Telegram channels** (public preview fetched via `t.me/s/<channel>`)

- [@seeallochnaya](https://t.me/s/seeallochnaya)
- [@TochkiNadAI](https://t.me/s/TochkiNadAI)
- [@denissexy](https://t.me/s/denissexy)
- [@rvnikita_blog](https://t.me/s/rvnikita_blog)
- [@ProductsAndStartups](https://t.me/s/ProductsAndStartups)

## Rubric

Ten picks, six minimum — a ceiling reached by finding ten things worth the
space, not a quota. Priority: AI tools, creative software, dev tools, privacy,
science, and anything you could apply this week.

## Layout

Each issue is a single self-contained HTML file at
`magazines/YYYY-MM-DD.html`. One spread per story, each with its own colour
and treatment — hero, midnight, pink, terminal, academic, big-stats, grid,
neon, dark report, editorial. Set in Fraunces + Inter via Google Fonts.

## Automation

A **local** launchd job (macOS) runs every Saturday at 08:00 Europe/Zurich and
invokes Claude Code in headless mode, following [`weekly-prompt.md`](./weekly-prompt.md):

1. Fetch all nineteen sources
2. Pick ten stories
3. Render `magazines/YYYY-MM-DD.html`
4. Rebuild `index.html` and commit to `main`
5. Push — GitHub Pages publishes the update
6. Post the fresh URL to the Telegram bot

**Why local, not a remote Claude trigger?** The notifier needs the Telegram
bot token, and the token lives in `.env` (gitignored). Keeping the scheduler
local means the token never leaves the machine.

### Install

```bash
ln -sf "$PWD/deploy/name.vadim.ephemeris.plist" \
  ~/Library/LaunchAgents/name.vadim.ephemeris.plist
launchctl bootstrap "gui/$UID" \
  ~/Library/LaunchAgents/name.vadim.ephemeris.plist
```

### Inspect

```bash
launchctl list | grep ephemeris
launchctl print "gui/$UID/name.vadim.ephemeris"
tail -f "$(ls -t .logs/*.log | head -1)"   # newest run; issues are weekly now
```

### Run now (dry-ish: actually publishes)

```bash
launchctl kickstart -k "gui/$UID/name.vadim.ephemeris"
```

### Unload

```bash
launchctl bootout "gui/$UID/name.vadim.ephemeris"
```

### Caveat

If the Mac is asleep on Saturday at 08:00, launchd catches the missed fire on
wake. If the Mac is off all weekend, the week is skipped — which now costs a
whole issue rather than one of seven. Use `pmset repeat wakeorpoweron S
07:55:00` (needs admin) for truly reliable delivery.

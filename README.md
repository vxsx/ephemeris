# FOMO-morning

A daily editorial digest of the best writing on AI tools, creative software,
dev tools, privacy and science — delivered every morning at **08:00 Zürich**
as a typographically over-the-top HTML magazine.

Live: https://vadim.sikora.name/fomo/

## Sources scanned every morning

**Newsletters / curation**

- [deeplearning.ai/the-batch](https://www.deeplearning.ai/the-batch/)
- [therundown.ai](https://www.therundown.ai/)
- [thezvi.substack.com](https://thezvi.substack.com/)
- [jack-clark.net](https://jack-clark.net/) (Import AI)
- [jeffbullas.com/jabs](https://www.jeffbullas.com/jabs/)

**Engineering blogs**

- [github.blog/category/engineering](https://github.blog/category/engineering/)
- [sentry.io/blog](https://sentry.io/blog/)
- [vercel.com/blog](https://vercel.com/blog)
- [posthog.com/blog](https://posthog.com/blog)
- [blog.cloudflare.com](https://blog.cloudflare.com/)
- [fly.io/blog](https://fly.io/blog/)

**Telegram channels** (public preview fetched via `t.me/s/<channel>`)

- [@seeallochnaya](https://t.me/s/seeallochnaya)
- [@TochkiNadAI](https://t.me/s/TochkiNadAI)
- [@denissexy](https://t.me/s/denissexy)
- [@rvnikita_blog](https://t.me/s/rvnikita_blog)
- [@ProductsAndStartups](https://t.me/s/ProductsAndStartups)

## Rubric

Ten picks. Priority: AI tools, creative software, dev tools, privacy, science,
and anything you could apply tomorrow.

## Layout

Each issue is a single self-contained HTML file at
`magazines/YYYY-MM-DD.html`. Ten spreads, one per story, each with its own
colour and treatment — hero, midnight, pink, terminal, academic, big-stats,
grid, neon, dark report, editorial. Set in Fraunces + Inter via Google Fonts.

## Automation

A **local** launchd job (macOS) runs every morning at 08:00 Europe/Zurich and
invokes Claude Code in headless mode, following [`daily-prompt.md`](./daily-prompt.md):

1. Fetch all six sources
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
ln -sf "$PWD/deploy/name.vadim.fomo-morning.plist" \
  ~/Library/LaunchAgents/name.vadim.fomo-morning.plist
launchctl bootstrap "gui/$UID" \
  ~/Library/LaunchAgents/name.vadim.fomo-morning.plist
```

### Inspect

```bash
launchctl list | grep fomo
launchctl print "gui/$UID/name.vadim.fomo-morning"
tail -f .logs/$(date +%Y-%m-%d).log
```

### Run now (dry-ish: actually publishes)

```bash
launchctl kickstart -k "gui/$UID/name.vadim.fomo-morning"
```

### Unload

```bash
launchctl bootout "gui/$UID/name.vadim.fomo-morning"
```

### Caveat

If the Mac is asleep at 08:00, launchd catches the missed fire on wake. If
the Mac is off, the day is skipped. Use `pmset repeat wakeorpoweron MTWRFSU
07:55:00` (needs admin) for truly reliable delivery.

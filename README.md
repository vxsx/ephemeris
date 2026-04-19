# FOMO-morning

A daily editorial digest of the best writing on AI tools, creative software,
dev tools, privacy and science — delivered every morning at **08:00 Zürich**
as a typographically over-the-top HTML magazine.

Live: https://vadim.sikora.name/fomo/

## Sources scanned every morning

- [every.to](https://every.to/)
- [deeplearning.ai/the-batch](https://www.deeplearning.ai/the-batch/)
- [therundown.ai](https://www.therundown.ai/)
- [thezvi.substack.com](https://thezvi.substack.com/)
- [jack-clark.net](https://jack-clark.net/) (Import AI)
- [jeffbullas.com/jabs](https://www.jeffbullas.com/jabs/)

## Rubric

Ten picks. Priority: AI tools, creative software, dev tools, privacy, science,
and anything you could apply tomorrow.

## Layout

Each issue is a single self-contained HTML file at
`magazines/YYYY-MM-DD.html`. Ten spreads, one per story, each with its own
colour and treatment — hero, midnight, pink, terminal, academic, big-stats,
grid, neon, dark report, editorial. Set in Fraunces + Inter via Google Fonts.

## Automation

A scheduled remote Claude agent runs every morning at 08:00 Zürich, following
[`daily-prompt.md`](./daily-prompt.md):

1. Fetch all six sources
2. Pick ten stories
3. Render `magazines/YYYY-MM-DD.html`
4. Rebuild `index.html` and commit to `main`
5. Push — GitHub Pages publishes the update
6. Post the fresh URL to the Telegram bot

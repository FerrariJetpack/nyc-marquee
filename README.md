# Marquee — NYC Showtimes

Every movie screen in New York City in one place, built to surface independent-theater
revivals of classic and older films alongside first-run listings.

**Live:** https://nyc-marquee.vercel.app

## What it does

Pick a day and see what's playing. Each day opens with up to three highlighted picks
(the oldest film on a screen that day, anything showing on a real film print, the best
late show), then the full schedule grouped into Morning / Matinee / Evening / Late night.
Search and filters — theater, genre, time of day, independent vs. major studio, and six
sort orders — stay collapsed behind a single control so the landing view stays clean.

Covers 19 venues: Film Forum, Metrograph, IFC Center, Anthology Film Archives, BAM,
Quad, Roxy, Paris Theater, Museum of the Moving Image, Film at Lincoln Center, both
Nitehawks, Angelika, Village East, plus the Alamo, AMC and Regal multiplexes.

## Files

| File | Purpose |
| --- | --- |
| `index.html` | The deployed page. Wraps `marquee.html` in a document skeleton. |
| `marquee.html` | Canonical source — the app plus its embedded listings data. |
| `refresh-prompt.md` | Instructions used by the daily agent that refreshes listings. |

## How the data works

Listings live in the `<script>` block of `marquee.html` as `F(...)` records:

```js
F(title, year, director, "Genre/Genre", theaterKey, "ind"|"maj", showtimes, opts)
```

`showtimes` uses day-of-month numbers with 24-hour times — `"7@1930,8@1415"` — and is
`null` when a theater hasn't published exact times, in which case `opts.r = [start, end]`
carries the run's date range instead. Showtimes are never invented: anything without a
published time is shown as a date range that links to the theater's own calendar.

Each record's "Tickets" button links to `opts.tix` when present — a direct link to that
film's own ticket page (or, where the booking system supports it, the exact showtime) —
falling back to the theater's general site otherwise. Ticket links are never guessed:
`opts.tix` is only set when it's been verified to point at that specific film.

## Deploying

The page is static and self-contained; no build step and no external requests.

```bash
vercel deploy --prod --yes
```

Connecting this repo to Vercel makes that automatic on every push.

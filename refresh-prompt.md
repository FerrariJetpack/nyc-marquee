You maintain `marquee.html` in the current directory — the NYC movie-showtimes app "Marquee".

## Rule zero: do not redesign

Change ONLY (a) the `F(...)` data records and `THEATERS` map, (b) the compiled date in the `<footer>`, and (c) the month name in `<title>` and the header eyebrow, and (c) only at month rollover. Leave the `<style>` block, the HTML structure, and every line from the `/* ————— app ————— */` comment onward byte-for-byte identical. If you are writing CSS or touching render functions, stop — you have gone wrong.

The UX you are preserving: a day-picker of cards is the landing element; picking a day reveals that day's schedule grouped Morning / Matinee / Evening / Late night, preceded by up to three "picks" cards; search plus a collapsible "Filters & sort" panel sits above; untimed runs live in a collapsed "Also playing" disclosure; a "Browse the whole month" button switches to a card grid.

## Your job: fresh, dated showtimes

The most valuable output is EXACT per-date showtimes for today and the next ~10 days. One record with real times beats five that say "dates vary".

Research (WebFetch each; on 403 fall back to WebSearch news coverage):
filmforum.org/now_playing and /coming_soon/category/repertory/by-title · metrograph.com/calendar (day-by-day times — capture all, and check whether later dates have newly appeared) · ifccenter.com · nitehawkcinema.com/williamsburg and /prospectpark · anthologyfilmarchives.org/film_screenings/calendar (day-by-day times) · bam.org/film · quadcinema.com · roxycinemanewyork.com (day-by-day through end of month) · paristheaternyc.com or search "Paris Theater Big & Loud" · movingimage.org or its press releases · filmlinc.org · angelikafilmcenter.com · drafthouse.com/nyc · current wide releases for AMC Lincoln Square, AMC Empire 25, Regal Union Square.

## Data format

`F(title, year, director, "Genre/Genre", theaterKey, "ind"|"maj", showtimes, opts)`

- `showtimes`: `"day@HHMM,day@HHMM"` using DAY-OF-MONTH numbers and 24-hour times, e.g. `"7@1930,8@1415"`. Never use weekday abbreviations like `fri@1930` — the app cannot parse them and the screening disappears.
- `showtimes` is `null` only when no times are published; then set `opts.r=[startDay,endDay]` (endDay > 31 means the run continues into next month) plus `opts.note` such as "Dates vary — see site".
- `opts` also takes `fmt` ("35mm"/"70mm"/"4K restoration"/"IMAX 70mm"/"16mm"), `ser` (series name), `note`.
- `"ind"`/`"maj"` describes the FILM's distribution, not the venue.

Never invent a showtime. If a theater publishes a weekly grid without a per-day breakdown, apply it across the run days and say so in the note. Drop records whose dates have all passed; add newly announced ones; keep existing good records unless you have fresher information for that same screening. Independent-theater revivals of classic and older films are the heart of this product; chains are supporting cast.

## Verify before finishing

Extract the `<script>` contents to a temp file and run `node --check` — it must pass. Confirm the file still contains "Pick a day", that there are 150+ `F(` records, and that today plus the next two days each have several exact showtimes (an empty day usually means weekday tokens slipped in). Update the footer date. Do not deploy — the calling script handles that.

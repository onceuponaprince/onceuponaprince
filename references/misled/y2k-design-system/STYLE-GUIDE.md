---
title: Misled — Y2K Style Guide
mode: Rave/Tech (brand-overridden)
generated_by: y2k-design-agent skill
date: 2026-04-21
---

# Misled — Y2K Style Guide

*Director's brief for any designer or developer producing visual work for misled.london. The brand sits inside the Y2K Rave/Tech tradition (1998–2002) but with a custom Acid Gold palette in place of the genre's default acid green.*

---

## Creative thesis

Misled lives in the friction between digital nostalgia and street authenticity. It is what a London skate kid in 2002 would have built as their personal site if they had access to Flash and a CRT monitor — a vaporwave horizon line, a pirate-radio marquee, an OS that crashed on purpose. The brand argues: *the herd uses clean modern UIs; we use a system that looks like it was compiled in someone's bedroom.*

This is **not** ironic Y2K. It is sincere — period-correct interface vocabulary deployed because that vocabulary still carries meaning to a generation that grew up watching their older cousins' Limewire downloads.

## What this aesthetic IS

1. **Maximalist.** Multiple animations on screen at once is correct, not noise. Scanline drift + pulsing CTA + scrolling marquee + blinking cursor coexist. The 2020s "less is more" instinct is wrong here.
2. **Bevelled and chrome-trimmed.** Every panel has a `2px` raised bevel (white-top, dark-bottom). Buttons depress visibly on press. Drop-shadows are hard offsets (`4px 4px 0 #FF71CE`), never blurred.
3. **Pixel-typed for system chrome, Anton-typed for human voice.** OS title bars and status strips use Press Start 2P or VT323. Headlines that speak as the brand use Anton (the brand's display choice). Body text uses Space Grotesk for readability. **Three voice register, three font families.**
4. **Dense and packed.** Whitespace is treated with suspicion. Sidebars, status bars, ornament stickers, visitor counters fill negative space. The page should look full at every scroll position.
5. **Gold-acid primary, neon trio secondary.** Acid Gold `#FFB800` for CTAs, headlines, glows. Holo Pink `#FF71CE` / Cyber Cyan `#01CDFE` / Astral Violet `#B967FF` for accents, scanline tints, glows on secondary elements. Void Black `#0D0015` ground. Blood Red `#FF003C` exclusively for danger-coded ornaments (UNDER CONSTRUCTION tape, error popups).
6. **Fixed-position interface furniture.** A status-bar footer pinned to the viewport. A scanline overlay site-wide. A marquee strip between content sections. Treat them as load-bearing structural elements, not decorative flourishes.
7. **Period-correct copy register.** System messages: `> SIGNAL ACQUIRED`, `> AWAITING INPUT`, `[ DROP INCOMING ]`. Status: `LAST UPDATED: 04.21.2026 // BEST VIEWED 1024x768`. UNDER CONSTRUCTION stickers are sincere, not winking.
8. **Glitched on purpose.** The hero headline gets a 4-second-loop glitch displacement. Loading bars half-fill and stop. Things look slightly broken — the brand earns trust by *not* being polished.

## What this aesthetic IS NOT

| ❌ Anti-pattern | Why it breaks period |
|---|---|
| Rounded corners (`border-radius > 0`) | Square or bevelled only — `border-radius` was barely supported in 1999 |
| Soft drop-shadows with blur | Hard offset shadows only: `4px 4px 0 #FF71CE` |
| Inter, DM Sans, Geist, modern sans-serifs | Use Verdana, Anton, Press Start 2P, VT323 |
| Whitespace-led "minimalist" layouts | Density is the point — sidebars, counters, marquees fill space |
| Smooth spring animations | Linear / easeOut only — springs are 2020s Material UI |
| `gap` flexbox / CSS grid for primary layout | Acceptable for 2026 build, but mimic table-like density |
| Rems / vw units in HTML output | px units — 1999 didn't think in viewport-relative |
| Glassmorphism / backdrop-blur | Solid bevelled chrome panels only |
| "Tasteful" colour use | The whole palette appears at once — restraint reads as wrong |
| SVG icon libraries (Lucide, Heroicons) | ASCII brackets, Unicode geometry, GIF-style sprites |

## Spatial logic

- **Vertical rhythm:** Hero (90vh, vaporwave horizon) → Marquee strip → Manifesto (window-chromed panel) → Tease (Win95 dialog) → Status bar (fixed bottom).
- **Horizontal density:** Page max-width settles around 1200px. Sidebars and floating ornaments push outwards into the canvas to avoid centred-column emptiness.
- **Layering:** Body sits on void. Panels float above with bevels and `4px 4px 0` hard shadows. Ornaments (UNDER CONSTRUCTION sticker, AOL Keyword tag, Error popup) sit on top with rotation and offset to break the grid.
- **Z-index stack:** scanlines = 60, status bar = 80, modal/tooltip = 100. Everything else under 50.

## Interaction philosophy

- **Hover:** every interactive element animates in <80ms. Bevelled buttons depress visibly. Glow states pulse on accent text.
- **Loading:** show a fake loading bar that fills to ~70% and pauses — the page has already loaded; the bar is decoration. Period-accurate frustration.
- **Cursor:** custom cursor on key surfaces (e.g. crosshair on hero, link-pointer on CTAs). Default OS cursor everywhere else — no fancy custom-cursor JS libraries.
- **Focus rings:** `2px dashed #FFB800` outlines (Y2K had visible focus; modern hide-then-show focus is wrong here).
- **Reduced motion:** marquee, matrix rain, glow pulse all kill cleanly under `prefers-reduced-motion: reduce`. Scanlines stay (they're texture, not motion).

## Typography hierarchy

| Layer | Font | Use |
|---|---|---|
| OS chrome | `Press Start 2P` 8-bit | Titlebar text, status-bar labels, system messages |
| Decorative all-caps | `VT323` terminal | Marquee, visitor counter, [BRACKETED] tags |
| Brand voice | `Anton` condensed | h1, h2 — the brand speaking as a person |
| Body | `Space Grotesk` / `Verdana` | Readable paragraphs |
| Mono prose | `Space Mono` | Eyebrow labels, terminal prefixes (`> THE THESIS`) |
| Decorative | `Syne 800` | Pull-quote attribution, marquee fallback |

## Reference period sites

Study these on archive.org for tone and density. These are the spiritual ancestors of misled.london's intended feel:

1. **`hampsterdance.com`** (1999) — single page, single loop, total commitment to the bit
2. **`spacejam.com`** (1996, classic version) — ASCII scaffold of every Y2K bedroom site
3. **Original `wired.com`** (~2000) — dense magazine layout, bevelled UI, neon accent
4. **`napster.com`** (~2001) — Rave/Tech aesthetic in a commercial product
5. **`ze.tt` / early Tumblr blogs** (~2008 vaporwave revival) — what informed the *current* vaporwave reading

For the audience, also: pirate-radio flyer design from London 2003-2008. The marquee strip and dense sidebars are the visual cousin of those flyers.

---

## Production checklist

When integrating Y2K tokens into a production build:

- [ ] Import `y2k-tokens.css` before any framework reset
- [ ] Add `Press Start 2P` and `VT323` via your font loader (`next/font`, etc.) as `--font-pixel` and `--font-vt`
- [ ] Wire site-wide scanline overlay via `body::after` with `mix-blend-mode: multiply`
- [ ] Define a fixed bottom status bar — visitor counter, last-updated, "best viewed" tag
- [ ] At least one full Win95 panel per page (titlebar + traffic-light controls + bevelled body)
- [ ] One marquee per page (between hero and first content section)
- [ ] Honour `prefers-reduced-motion` for marquee, glow-pulse, glitch-shift, matrix-fall
- [ ] Validate: no `border-radius`, no blurred drop-shadows, no spring animations

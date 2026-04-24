# How a four-word bug in my Chrome extension quietly blocked every Google scraper I might ever build

*A small tool-build session turned into an archaeology expedition. The thing that was wrong was upstream of everything.*

## The setup

I work across three LLMs at once. Claude for building. Gemini as a cross-check and a research companion. A third model for web-grounded queries. Each one earns its place — they're good at different things — but they're also walled gardens. Conversations do not cross. If I want to carry a Gemini research thread into a Claude Code session, my options are to paste the whole transcript (which eats ten thousand tokens of Claude's context budget) or to retype the relevant fragment (which loses context and burns time). Neither of those is a solution. They're the problem the solution is supposed to replace.

So I had decided to build a small Rust CLI called `fast-travel-cli`. Its job is narrow: read a Gemini conversation by URL, extract the messages, emit them as markdown to stdout. Claude can then consume the output via shell pipe without the user ever pasting a transcript. A context-hygiene tool.

## What I walked back into

I had scaffolded the tool in a previous session and stopped. When I came back to ship it, the forty-five-byte placeholder I remembered had quietly accumulated 421 lines of broken Rust code.

I knew why. The session where the scaffolding lived had run out of Claude credits mid-flight, and I had asked Gemini to write the first pass instead. Gemini had done something interesting: it had written what it thought the tool should be, not what the spec said it was. The spec was single-provider (Gemini only), single-command, stateless, markdown to stdout. Gemini had produced a multi-provider tool (ChatGPT, Claude, Gemini, generic) with three subcommands (sync, extract, search), a local index system, and dead code from two separate implementations merged into one file. It did not compile.

This is a known trade. When you run out of Claude usage and switch to Gemini to keep moving, you get code. The code reflects Gemini's capabilities on whatever surface you are building against. It needs fixing back toward the original spec, not inherited wholesale. I spent the first stretch of the session deleting most of what was there, keeping only the DOM selectors — because those were the one piece of real reverse-engineering, and Gemini had actually gone and inspected Gemini's own UI to produce them.

## The first stall

First headless run against a real Gemini conversation URL: timed out waiting for the conversation DOM to render. I had two theories. Either the cookies I was injecting were insufficient and Gemini was rendering a signed-out landing UI instead of the conversation. Or Gemini had shipped a UI update since the original selectors were captured and they had drifted. Both plausible. Headless browser logs could not distinguish them.

So I added a `--visible` flag — launch Chromium with a visible window — and an on-timeout diagnostics dump: URL, page title, selector match counts, and the first eight hundred characters of `document.body.innerText`. One extra run would give me enough information to pick a theory.

## What the diagnostics actually found

Neither hypothesis was right.

The browser had been redirected to `https://consent.google.com/m?continue=https://gemini.google.com/app/9053dffe78ffe1d4&gl=GB&m=0&pc=bard&cm=2&hl=en-US&src=1`. The page title read *Before you continue*. The body rendered Google's familiar GDPR consent dialog: *We use cookies and data to deliver and maintain Google services, track outages and protect against spam, fraud, and abuse…*

The `gl=GB` parameter in the URL named the root cause. I am in the UK. Google applies GDPR consent gating to every fresh session for European users, and the consent decision lives in a cookie. If that cookie is not present when the browser visits a Google property, Google intercepts every navigation with the consent wall until the user clicks *Accept all* or *Reject all*.

My cookie file had four cookies. All analytics. All scoped to `.gemini.google.com`. Google's consent state lives in cookies called `CONSENT` and `SOCS`. Google's authenticated session state lives in `SID`, `SSID`, `HSID`, `APISID`, `SAPISID`, and `__Secure-1PSID` / `__Secure-3PSID`. All of those live on `.google.com` — the parent domain. None of them were in my export.

The cookies I *was* exporting were not the cookies Google needed to see.

## Where the bug actually lived

The export was coming from a Chrome extension I had built myself, called `cookie-master-key`. It is a small thing — sixty-six lines of JavaScript, one popup button. Its job is to take whatever tab you are on and write a JSON file with the cookies that apply to it, so any of my scrapers can read from a shared directory and reuse the user's authenticated sessions without anyone ever typing a password again.

I opened the source. The bug was one line:

```javascript
chrome.cookies.getAll({ domain: url.hostname }, ...)
```

Chrome's `chrome.cookies.getAll` API takes a filter object. With `{ domain: X }`, it returns cookies whose domain is `X` or a subdomain of `X`. It does *not* return cookies on parent domains.

When you run the extension on a tab at `gemini.google.com`, `url.hostname` evaluates to `"gemini.google.com"`, and the API returns cookies scoped to `gemini.google.com` or its subdomains. The entire `.google.com` cookie jar — including every session and consent cookie — is silently excluded.

The right call is `{ url: tab.url }`. With a URL filter, Chrome's question becomes *which cookies would be sent if I made a request to this URL?* — and the answer is all of them, parent-domain cookies included. That is what an export tool actually wants.

The fix was four words: `domain: url.hostname` → `url: tab.url`.

## The result

Reloaded the extension. Re-exported from an authenticated Gemini tab. The cookie file went from four cookies to twenty-three — four on `.gemini.google.com` (the analytics ones from before) and nineteen on `.google.com`, including every session cookie Gemini had been waiting to see.

Re-ran `fast-travel-cli` headless. Past the consent wall. Into the conversation view. Extracted thirty messages from the reference URL and rendered them to stdout as markdown.

The conversation it round-tripped was the one where Gemini had written the broken code this session had opened by fixing. The tool's first read was its own origin story.

## The part that mattered

The real work in this session was not the Rust CLI. It shipped, and that is fine, but if I had framed the session as *build fast-travel-cli* and stopped at getting it green, I would have missed the thing that actually mattered.

The stall at the tip of one product was a symptom of a broken Chrome extension that had been shipping narrow cookie exports across multiple projects for weeks. Every tool I had built or might build that touched any Google property — Gemini today, but also Drive, Docs, YouTube, Colab, anything that comes next — was inheriting the same narrow export. Every one of them was going to hit the same consent wall the first time it tried to reach past its hostname on a GDPR jurisdiction.

I could have fixed `fast-travel-cli` at the tip — add a `consent.google.com` detection, click *Reject all* programmatically, paper over the symptom. It would have made the one tool work. It would have left every other consumer of the extension still broken. It would have looked like a fix and been a detour.

The upstream fix in the extension — four words — solved all of them at once. Including tools that do not exist yet and will inherit the fix for free.

This is a pattern that compounds. Tip-fixes solve the tip. Upstream fixes solve every downstream consumer, retroactively, forever. When a stall in one tool points at shared infrastructure, following the pointer is almost always worth the cost of pausing the tool-level work.

The session I thought was about a 212-line Rust CLI was actually about four words in a 66-line Chrome extension.

## The ship

- **fast-travel-cli** — Gemini conversations to clean markdown on stdout. Cookie-reuse session-based, no API-key dependency.
- **cookie-master-key** — Chrome extension, URL-scoped exports including parent-domain cookies.
- **ghostroute** — monorepo of side-LLM scrapers, now documented as a context-hygiene layer.

If you run multiple LLM sessions concurrently and want to carry conversation state between them without blowing context budgets, feel free to fork. The pattern generalises — any site you can log into, you can scrape via session-reuse — so adding a new provider is mostly selector work.

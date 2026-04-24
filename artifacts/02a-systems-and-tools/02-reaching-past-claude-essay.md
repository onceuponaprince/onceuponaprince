# The four-word bug

I sat down to ship a small Rust CLI that carries Gemini conversations into Claude without pasting transcripts. A narrow context-hygiene tool: read a conversation by URL, extract the messages, emit markdown to stdout. Claude consumes the output via shell pipe, and the user's Gemini research thread stops costing ten thousand tokens of Claude's context budget every time it gets referenced.

My Claude credits had run out the session before. So I'd asked Gemini to write the first pass. When I came back to finish it, the 45-byte placeholder I remembered had quietly accumulated 421 lines of broken Gemini-written code.

## What Gemini wrote

It didn't compile. Missing struct definitions. API calls that didn't match chromiumoxide's actual shape. Dead code after a returning match. Two separate implementations merged into one file. A `Provider` enum the spec had never mentioned, clap subcommands the spec had never asked for, a local index system the spec had explicitly put out of scope.

Gemini had written what it thought the tool should be, not what the spec said it was.

This is a known trade. When Claude credits run out mid-session and you switch to Gemini to keep moving, the code reflects Gemini's capabilities on whatever surface you're building against. It needs fixing back toward the original spec, not inherited wholesale. Reshaping was mostly deletion — strip the enum, strip the subcommands, strip the index, keep the DOM selectors. Those were the only part worth preserving, because Gemini had actually inspected Gemini's own UI to produce them.

## The first stall

First headless run against a real conversation URL: timed out waiting for the DOM.

Two candidate causes. Cookies insufficient, so Gemini was rendering a signed-out landing UI that didn't match the conversation selectors. Or selectors drifted since the Gemini code had captured them, and the tool was polling for elements that no longer exist. Both plausible. Headless logs couldn't distinguish.

So I added a `--visible` flag — launch Chromium with a visible window — and an on-timeout diagnostics dump: URL, page title, selector match counts, first eight hundred characters of `document.body.innerText`. One run would be enough information to pick a theory.

## What the diagnostics actually found

Neither hypothesis was right.

The browser had been redirected to `https://consent.google.com/m?continue=https://gemini.google.com/app/...&gl=GB&m=0&pc=bard`. The page title read *Before you continue.* The body rendered Google's familiar GDPR consent dialog.

The `gl=GB` parameter in the URL named the cause. UK jurisdiction. Google applies GDPR consent gating to every fresh session for European users, and the consent decision lives in a cookie. If that cookie isn't present when the browser visits a Google property, Google intercepts every navigation with the consent wall until the user clicks through.

My cookie file had four cookies. All analytics. All scoped to `.gemini.google.com`. Google's consent state (`CONSENT`, `SOCS`) and session state (`SID`, `SSID`, `HSID`, `APISID`, `SAPISID`, `__Secure-1PSID`, `__Secure-3PSID`) all live on `.google.com` — the parent domain. None of those were in the export.

The cookies I *was* exporting weren't the cookies Google needed to see.

## Where the bug actually lived

The export was coming from a Chrome extension I'd written myself — sixty-six lines of JavaScript, one popup button, one file. Its job is to take whatever tab you're on and write a JSON file with the cookies that apply to it, so any of my scrapers can reuse the user's authenticated sessions without anyone ever typing a password again.

I opened the source. The bug was one line:

```javascript
chrome.cookies.getAll({ domain: url.hostname }, ...)
```

Chrome's `chrome.cookies.getAll` takes a filter object. With `{ domain: X }`, it returns cookies whose domain is `X` or a subdomain of `X`. It does not return cookies on parent domains. When you run the extension on a tab at `gemini.google.com`, `url.hostname` evaluates to `"gemini.google.com"`, and the API returns cookies on `gemini.google.com` or its subdomains. The entire `.google.com` cookie jar — session, consent, authentication — is silently excluded.

The right call is `{ url: tab.url }`. With a URL filter, Chrome's question becomes *which cookies would be sent if I made a request to this URL?* — and the answer is all of them, parent-domain cookies included. That is what an export tool actually wants.

Four words of change.

## The result

Re-exported from an authenticated Gemini tab. The cookie file went from four cookies to twenty-three — four on `.gemini.google.com` (the analytics ones from before) and nineteen on `.google.com`, including every session cookie Gemini had been waiting to see.

Re-ran the tool headless. Past the consent wall. Into the conversation view. Extracted thirty messages and rendered them to stdout as markdown.

The conversation it round-tripped was the prior Gemini session that had written the broken code this session had opened by fixing. The tool's first read was its own origin story.

## The part that mattered

The real work wasn't the tool.

The tool ships. It closes a small context-hygiene problem. But if I'd framed the session as *build fast-travel-cli* and stopped at getting it green, I would have missed the thing that actually mattered.

The stall at the tip of one product — a single Rust CLI, one narrow use case — was a symptom of a broken Chrome extension that had been shipping narrow cookie exports across multiple projects for weeks. Every tool I had built or might ever build that touched any Google property — Gemini today, but also Drive, Docs, YouTube, Colab, anything that comes next — was inheriting the same narrow export. Every one of them was going to hit the same consent wall the first time it tried to reach past its hostname on a GDPR jurisdiction.

A tip-fix in fast-travel-cli — say, a `consent.google.com` detection and a programmatic *Reject all* click — would have solved the one tool. It would have left every other consumer of the extension still broken, still quietly blocked on whatever different wall they hit first. It would have looked like a fix and been a detour.

The upstream fix in the extension — four words — solved all of them at once. Including tools that do not exist yet and will inherit the fix for free.

This is a pattern that compounds. Tip-fixes solve the tip. Upstream fixes solve every downstream consumer, retroactively, forever. When a stall at the tip of one tool points at shared infrastructure, following the pointer is almost always worth the cost of pausing the tool-level work.

The session I thought was about a 212-line Rust CLI was actually about four words in a 66-line Chrome extension.

---

Shipped:

- **fast-travel-cli** — Gemini conversations to clean markdown on stdout; cookie-reuse session-based, no API-key dependency.
- **cookie-master-key** — Chrome extension, URL-scoped exports that include parent-domain cookies.
- **ghostroute** — monorepo of side-LLM scrapers, now documented as a context-hygiene layer.

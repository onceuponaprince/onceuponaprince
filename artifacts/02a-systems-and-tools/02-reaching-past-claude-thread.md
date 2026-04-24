1/ Sat down to ship a small Rust CLI that carries Gemini conversations into Claude without pasting transcripts.

My Claude credits had run out the session before. So I'd asked Gemini to write the first pass.

When I came back to finish it, the 45-byte placeholder had quietly accumulated 421 lines of broken Gemini-written code.

2/ It didn't compile. Missing struct definitions, API calls that didn't match chromiumoxide's actual shape, dead code after a returning match, two separate implementations merged into one file.

Reshaping it was mostly deletion. Strip the Provider enum, strip the subcommands, strip the index, keep the DOM selectors — those were the one piece of real reverse-engineering.

3/ First headless run: timed out waiting for the conversation DOM.

Two candidate diagnoses. Cookies insufficient, so Gemini was rendering a signed-out landing UI. Or selectors drifted since the Gemini code captured them. Both plausible. Headless logs couldn't distinguish.

4/ Added a `--visible` flag and on-timeout diagnostics — URL, page title, selector counts, first 800 chars of body text.

One run. Neither hypothesis.

The URL had been redirected to `consent.google.com/m?continue=...&gl=GB&m=0&pc=bard`. Google's GDPR consent wall. Title: *"Before you continue."*

5/ The cookie file had four cookies. All analytics. All scoped to `.gemini.google.com`.

Google's consent state (CONSENT, SOCS) and session cookies (SID, SSID, HSID, APISID, SAPISID, __Secure-1PSID / 3PSID) live on `.google.com` — the parent domain. None of those were in the export.

6/ The export was coming from my own Chrome extension. I opened the source. One line:

```
chrome.cookies.getAll({ domain: url.hostname }, ...)
```

Chrome's `domain` filter matches the hostname and its subdomains. It does not match parent-domain cookies. The right call is `{ url: tab.url }` — returns every cookie that would be sent with a request to that URL.

Four words of change.

7/ Re-exported. Cookie file went from 4 cookies to 23. All the session cookies were there.

Re-ran the tool headless. Past the consent wall. Into the conversation view. Extracted 30 messages, rendered to stdout as markdown.

The conversation it round-tripped was the prior Gemini session that wrote the broken code this one had opened by fixing. The tool's first read was its own origin story.

8/ The real work wasn't the tool.

The stall at the tip of one product was a broken Chrome extension quietly infecting every downstream consumer. Every Google-property scraper I'd ever build — Drive, Docs, YouTube, anything — was inheriting the same narrow export.

A tip-fix would have solved the tip. The upstream fix solved all of them at once.

9/ Tip-fixes solve the tip. Upstream fixes solve every downstream consumer, retroactively, forever.

When a stall in one tool points at shared infrastructure, follow the pointer.

The session I thought was about a 212-line Rust CLI was actually about four words in a 66-line Chrome extension.

[essay →]

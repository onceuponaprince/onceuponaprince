# Eight bugs to type into Grok

*What four hours of debugging one research CLI taught us about selector decay, layered failures, and why each fix only uncovers the next.*

The plan was simple. Recover one research source. Episode 2 of the agent-architecture campaign had concluded on five-of-seven sources because two browser-based CLIs failed in the original session — Perplexity and Grok. Perplexity had been recovered earlier. Grok was still blocked. Tonight's job: fire the Grok CLI, capture the response, dispatch the addendum.

Four hours later we had eight fixes, a substantively hardened CLI, a 2,993-character Grok response on Episode 2's question, and a structural observation about how brittle browser-automation selectors are when the target is a fast-moving SPA.

This essay is about the eight layers and what they share.

## Layer one: the keymap

The original failure was a hang at the typing step. Drunk-Typist — a per-character humanised input pattern — would lock up partway through the prompt with no further output. The earlier diagnosis had recorded this as *"Failed to paste previous context into input field: Key not found: ≥"*. That error was the giveaway.

`chromiumoxide`, the Rust CDP client the CLI uses, dispatches per-character keyboard events through a synthetic keymap. The keymap covers ASCII plus a handful of common punctuation. It does not cover `≥`, em-dashes, curly quotes, ellipsis, NBSP, or arrows. The Ep2 prompt contained `→` (U+2192, three occurrences). Drunk-Typist tried to type the arrow, the keymap said no, `chromiumoxide` returned an error, the future hung waiting for a key event that would never come.

The fix bypasses the keymap entirely. CDP's `Input.insertText` inserts text directly without dispatching `keydown`/`keyup` events. It is what Playwright uses under the hood for `page.fill()`. We replaced the per-character `Element::type_str()` call with a `Page::execute(InsertTextParams)` call. The fix removed about fifty lines of Unicode-sanitiser code along the way: the workaround existed to dodge the keymap; once the keymap was out of the path, the workaround was dead.

## Layer two: the input selector

With typing fixed, the next run got further but failed at locating the chat input. The original selector — `div[contenteditable="true"][tabindex="0"]` — no longer matched anything visible within twelve seconds. Grok's UI had shipped a change since the CLI was written.

The user inspected the live page and gave us the new shape: `div.tiptap.ProseMirror[contenteditable="true"]`. `tiptap` and `ProseMirror` are the editor library's own root classes. They are stable across xAI's UI shuffles unless the team swaps editors entirely. A class-based selector is more durable than the original tabindex-plus-contenteditable combination, which the page now has multiple of: search box, hidden drafts, the actual input.

## Layer three: chromium suicide

The next run got past the input lookup and into typing. Then chromium silently exited. The Rust process held its CDP websocket open against a dead browser, and `page.find_elements()` blocked forever waiting for a response that would never arrive.

The historic diagnosis had named the likely cause: missing launch hardening flags. `chromiumoxide`'s default `BrowserConfig` only included `--no-sandbox`. Modern headless Chromium needs more. We added `--disable-dev-shm-usage` (the default `/dev/shm` is 64 MB; Grok's React tree blows past that and the renderer dies silently), `--disable-gpu` (the GPU process death cascades into renderer death), `--disable-blink-features=AutomationControlled` (`navigator.webdriver = true` is the cheapest anti-bot tell), and a per-pid `--user-data-dir=/tmp/grok-$PID` so concurrent runs do not share a profile lock.

After that round chromium stayed alive.

## Layer four: memory pollution

The CLI maintains a JSON memory file at `<git-root>/.claude/.swarm-memory.json` that tracks dialogue history across runs. Failed runs across the session had been writing the wrong thing to it: captured user-message bubbles that the broken response selector had returned as if they were Grok's replies. Each new run loaded that polluted history and pasted it back into Grok as *"previous context"*, which meant Grok was being told its own earlier non-replies were prior turns.

The cleanup script we had been running wiped the wrong path. The binary uses `git rev-parse --show-toplevel` from the current working directory — and we had been running from `build-in-public`, not from `ghostroute`. The script wiped `ghostroute/.claude/`. `build-in-public/.claude/` was twenty kilobytes of accumulated nonsense. Each run had been compounding earlier failures.

This was the only bug of the night that was operator error, not code. It belongs in this list anyway because the *symptom* — the captured response containing system directives we never typed — sent us looking for a CLI bug that did not exist.

## Layer five: cookie merge

With clean memory the visible browser opened and stalled at a login wall. Cookies had been refreshed by the user but the browser stayed unauthenticated.

The cookie loader read the first `*-cookies.json` it found via filesystem iteration order (alphabetical). The user has six such files: `chatgpt`, `claude`, `gemini`, `grok`, `perplexity`, `x.com`. Grok's authentication binds to *both* `grok.com` and `x.com` — it is X's SSO. Loading only the first file gave us half the auth state.

The fix loads every `*-cookies.json` in the directory, parses each as a JSON array, concatenates the arrays, and injects the merged set. With 102 cookies across six providers loaded, login succeeded on the next run.

The side effect was unintended. The binary now authenticates against every model platform whose cookies sit in that directory. The same code that fixed Grok login also makes the CLI a working multi-platform research orchestrator. We did not set out to build that. It fell out of doing the obvious right thing for the smaller problem.

## Layer six: submit not firing

Login worked. Instant-paste filled the input. The Enter key was pressed. The submit did not happen.

`Input.insertText` fires the native `input` event but not `keydown` / `keyup`. Tiptap and ProseMirror — the editors Grok runs on — listen to `input` events for content updates *but* maintain a parallel React-controlled-input state that only re-reads on certain triggers. Without a keydown signal, React's state stayed at its empty initial value. Pressing Enter on a contenteditable that the framework thinks is empty does nothing.

The fix is a single page-evaluate call after `insertText`: dispatch a synthetic `InputEvent` on the focused element. The framework sees it, re-reads the contenteditable, registers the content, enables the submit button, and Enter sends the message.

This was the most embarrassing of the eight. The whole point of `Input.insertText` is that it is the *right* way to insert text without keyboard fakery. The cost is that frameworks built atop the keyboard pipeline do not know they have new content. The fix is to nudge them. It is two lines of JavaScript.

## Layer seven: capturing the user's own message

With submit working the binary returned a response in 7 seconds — far too fast for a 4 KB research prompt. The "response" was the first 843 characters of the user's own prompt.

The response selector matched both the user-message bubble and the assistant reply bubble. They share `div[id^="response-"]` and `.message-bubble` markup. With a long prompt, Grok's response had not begun rendering yet at the 7-second mark. Only the user bubble matched the selector. The stability check — text unchanged for 1.4 seconds — fired immediately, returned the user bubble as if it were Grok's reply, and saved it to memory.

The fix is a two-element gate. Require at least two matching elements before accepting any candidate. With only one element, the only thing to capture is the user echo, which is by definition not yet a response.

## Layer eight: the bullets

The element gate worked. We got Grok's actual reply this time — substantive, on-thesis, with citations preserved. But sections like *"Survivors:"* and *"Rollbacks:"* rendered without their bullet content. `innerText` on the response container did not traverse some of the rendered children — likely closed `<details>` elements or shadow DOM.

This one we did not solve. The captured response is enough for the addendum but bullets-under-headers will need a different approach in a future scene.

## What the layers share

Every layer of this stack was hiding the next one. We thought we had a typing bug. We had eight bugs. Each fix peeled back one symptom and exposed the next. Until you fix the layer you can see you cannot prove the next layer is broken — and until you fix the layer below, the layer above might keep regressing.

The deeper observation is about *selector decay*. Three of the eight bugs — input selector, response container, inner content selector — were the same shape: a specific CSS selector against a fast-moving SPA. xAI ships UI changes weekly. Every selector in the CLI that names a Grok-specific class will rot. The durable answer is not better selectors. It is *probe-and-iterate infrastructure* — DOM dumps on locator failure, element-count gates, content-length sanity checks — so the CLI surfaces enough about the page state on its own to make the next selector update fast.

The probe we added on `find_visible_locator` failures is the first step. The element-count gate is the second. There are more. They earn their place because they make the *next* failure easier to debug, not because they make the current one go away.

## What banks tonight

A working ask-grok-cli with eight fixes that compose. A 2,993-character Grok response on the Episode 2 question, captured in 38 seconds end-to-end with `--instant-paste`. A `--prompt-file` flag for prompts that exceed shell argv limits. A cookie loader that authenticates against every platform whose cookies sit in the directory. A DOM-state probe that gives diagnostic output for free on the next selector failure.

What does not bank: the bullet-rendering issue, the memory-path bug (still cwd-derived; should be binary-relative), and the open question of whether Grok's response container has a stable inside-or-outside discriminator we have not found yet.

The Ep2 addendum can dispatch with the recovered Grok source. The campaign moves. The CLI is durable enough to fire next time without a four-hour debugging session preceding it.

The thesis says *building a startup should feel like playing a game, and the act of playing it should produce the narrative that sells it.* Tonight was a game. Eight boss fights, each unlocking the next room. The narrative is this essay. The debugging session was the work. The work is the story.

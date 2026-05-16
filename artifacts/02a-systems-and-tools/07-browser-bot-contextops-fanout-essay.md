# The Green Hallucination

*A research pipeline lied to me with a passing status code. The bug was not the model.*

The most expensive bug I shipped this week did not crash. It returned `200 OK`. It marked its own output `usable`. And it was confidently, fluently, completely wrong. I want to lead with that, because every instinct in software tells you green means good, and this was the week green tried to kill me.

The setup: I had a question worth asking across more than one brain. Which of two dozen of my own code projects has a SaaS hiding in it. So I built a pipeline that fans one prompt across five engines (Gemini, DeepSeek, Grok, Perplexity, and a local model), each driven through a real browser session, and reconciles the answers. Ask five, trust none individually, triangulate. That part worked. The part that did not work is the reason this is an essay and not a changelog.

## 1. The honest failure

The first thing that broke was loud, and I am grateful for it.

Run one engine on its own: a clean answer in nineteen seconds. Run two of them at once through the fanout: `502`, a killed driver, `[Errno 111] Connection refused`. Solo, fine. Concurrent, dead. The classic shape of a contention bug, and I chased it like one.

The cause was specific and slightly absurd. `undetected-chromedriver`, the stealth layer that lets these sessions look human, patches a *single shared binary on disk* every time it launches Chrome. Two launches at once race on that one file and on port allocation, and one of them executes the other. Not slows it. Kills it. The fix was a process-wide `asyncio.Lock` that serialises the whole selenium session lifetime, so the two stealth browsers take turns instead of knifing each other in a shared cloakroom. Playwright sessions, which do not share that binary, stay concurrent and untouched.

That bug cost me an afternoon. It was cheap, and it was cheap *because it crashed*. A crash is a system telling you the truth at the top of its voice. Hold that thought. (This will be useful later.)

## 2. The dishonest one

Then I changed the workload from a one-word test prompt to the real research prompt. Twelve hundred characters of context. And the pipeline went green.

Gemini returned an answer. Status `usable`. DeepSeek too. The validator was satisfied: non-empty, not a refusal, not an obvious echo. By every gate I had, it passed. So I read it.

My candidate C2 was an LLM cost-router. Gemini's analysis of C2 came back as "Real-Time Local AI Agents for Industrial IoT". Every single candidate had been remapped to a confident, well-structured, totally unrelated product. The model had not failed to answer. It had answered beautifully. It had just answered a different question, the one it could reconstruct from the wreckage of the one I sent.

Because I had wrecked it. I instrumented the input and measured: 1652 characters sent, 1418 landed in the editor. Fourteen percent of the prompt, gone, scattered through the middle, where the candidate definitions lived. The cause was a line of code I would have called boring: `keyboard.type(text)`. Synthetic keystrokes, one per character, at zero delay, into a ProseMirror rich-text editor whose async input handler simply cannot keep pace. The tail survived. The middle did not. The model got a coherent-looking ruin and did what good models do with ruins: it filled them in.

Here is the consensus position, and it is wrong. "The AI hallucinated." It did not. **I** truncated the prompt, silently, and never checked, and then I blamed the thing downstream of my mistake. The hallucination was input-side. The model was the only honest component in the chain.

Distributed systems has had the right vocabulary for this for forty years. A *fail-stop* fault is a component that dies cleanly: you know it is gone. A *fail-silent* fault is worse: the component stops doing its job and says nothing. The worst class, the *Byzantine* fault, is a component that keeps reporting healthy while emitting plausible garbage. My fanout had a Byzantine fault and a green dashboard, which is the engineering definition of the Emperor with no clothes. Everyone in the pipeline nodded at the fabric. The `200` was the fabric.

Lay the chain out, because each link is individually defensible. Typing into a focused editor is correct. Reading back a non-empty response is a reasonable liveness check. A non-empty, non-refusal answer is, in isolation, "usable". A is sound, B is sound, C is sound. Therefore a fabricated market analysis ships with a green checkmark. The chain is valid. The conclusion is a lie. That is what fail-silent buys you: locally correct, globally false.

## 3. The fix is a refusal

The instinct is to make the typing more reliable. That is treating the symptom. The actual fix has two halves, and only one of them is about typing.

Half one: stop typing. `keyboard.insert_text()` in Playwright, and the CDP `Input.insertText` primitive for the stealth path, commit the whole string in a single atomic event instead of a hundred racing keystrokes. Measured after: 1407 sent, 1405 landed, the two-character delta being benign whitespace the editor normalised. Fine.

Half two is the one that matters. After entering the prompt, the code now reads the editor back and asserts that what is there is what I meant to send. If it is not, it does not proceed. It raises. The lane fails, loudly, with a reason. I converted a Byzantine fault into a fail-stop one on purpose, because a pipeline that cannot lie to you is worth more than a pipeline that is usually right. This is the whole of it: **validate the question, not just the answer.** Everyone instruments their outputs. Almost nobody asserts their inputs survived the trip.

There is a reason this matters beyond one fanout. The thesis I build under is that software should be an extension of human choice, never a surrogate for it. A system that fabricates when its input is corrupted, and reports success while doing so, has not made an error. It has quietly removed your ability to know you were misled. The read-back assertion is not a bug fix. It is the system being made to tell the truth about its own ignorance.

And the discipline cuts both ways, which I enjoyed less. When I ran the full test suite on the merged result, the Rust workspace passed clean, 409 tests, and the Python suite caught exactly one failure: my own fix, breaking a test double that still expected the old typing call. The gate did to me precisely what I had just built it to do to the model. Good. I fixed the double properly so it exercised the new guard, watched 44 tests go green, then landed the lot: infra fixes in their own commit, the unrelated work-in-progress snapshotted separately so nothing entangled, six worktree branches merged, reconciled, pushed. No broken intermediate state. The crash-shaped honesty I was grateful for in chapter one is the same honesty I spent chapter three forcing into a thing that did not want to give it.

A crash is a component telling you it failed. A hallucination is a component telling you it succeeded. Build for the second one, because the first one was always going to be fine. Green was never the same as correct. It just looked the part, and looking the part is exactly the problem.

---

## Publishing

Canonical: **Medium** (no `canonical_url` on Medium itself). Cross-posts must point at the live Medium URL once published. Publish order: Medium first, then paste its URL into the others.

- **Medium (canonical):** title *The Green Hallucination*; subtitle *A research pipeline lied to me with a passing status code. The bug was not the model.*; tags: `Software Engineering`, `Debugging`, `AI`, `Distributed Systems`, `Build In Public`; ~6 min read.
- **Dev.to:** frontmatter `title`, `published: true`, `description`, `tags: ai, debugging, python, buildinpublic`, `canonical_url: <MEDIUM_URL>`.
- **Hashnode:** `title`, `subtitle`, `tags: ai, debugging, python`, `canonical: <MEDIUM_URL>`, `slug: the-green-hallucination`.
- **Twitter/X:** see `[[07-browser-bot-contextops-fanout-thread]]`; final tweet links `<MEDIUM_URL>`.

`<MEDIUM_URL>` = paste the Medium article URL after publishing (Medium generates it on publish). Mandatory for the three cross-posts or they SEO-collide with the canonical.

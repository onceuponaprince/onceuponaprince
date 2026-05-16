# The Green Hallucination — thread

*Twitter/X thread derived from `[[07-browser-bot-contextops-fanout-essay]]`. Canonical: Medium. Final tweet links `<MEDIUM_URL>` (paste after Medium publish).*

---

**1/** The most expensive bug I shipped this week did not crash. It returned `200 OK`. It marked its own output "usable". And it was confidently, completely wrong. Green tried to kill me.

**2/** I built a pipeline that fans one research prompt across five AI engines (Gemini, DeepSeek, Grok, Perplexity, a local model) through real browser sessions and reconciles the answers. Ask five, trust none alone, triangulate.

**3/** First bug was loud. Solo: clean answer in 19s. Two engines concurrent: `502`, killed driver, `[Errno 111]`. `undetected-chromedriver` patches one shared binary on disk per launch. Two launches race on it. One executes the other.

**4/** Fixed with a process-wide lock so the stealth browsers take turns. That bug cost an afternoon. It was cheap, and it was cheap *because it crashed*. A crash is a system telling you the truth at the top of its voice.

**5/** Then I sent the real prompt. 1200 chars. Pipeline went green. Status: `usable`. So I read it. My "LLM cost-router" candidate came back analysed as "Real-Time Local AI Agents for Industrial IoT". Every candidate, confidently remapped to the wrong product.

**6/** I instrumented the input. 1652 chars sent, 1418 landed. `keyboard.type()` at zero delay drops ~14% into a ProseMirror editor that cannot keep pace. The model did not hallucinate. I mutilated the prompt and never checked, then blamed the model.

**7/** Distributed systems named this 40 years ago. fail-stop = dies cleanly. fail-silent = stops, says nothing. Byzantine = keeps reporting healthy while emitting plausible garbage. My fanout had a Byzantine fault and a green dashboard.

**8/** Fix, half one: stop typing. `keyboard.insert_text` / CDP `Input.insertText` commit the whole string atomically. 1407 sent, 1405 landed.

**9/** Fix, half two, the one that matters: read the input back and assert it survived. If not, raise. Fail loud. I turned a Byzantine fault into a fail-stop one on purpose. Validate the question, not just the answer.

**10/** Everyone instruments outputs. Almost nobody asserts the input made the trip. A crash is a component saying it failed. A hallucination is a component saying it succeeded. Build for the second one. Green was never the same as correct.

**11/** Full write-up: `<MEDIUM_URL>`

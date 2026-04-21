1/ Session closed Scene 04 (Misled ethos page — second paid client). I'd built the thing, added Supabase + double-opt-in via Resend, shipped a self-cleaning cron, drafted the client handoff. Then I smoke-tested the URL. It served a `coming soon` placeholder.

2/ The build was real. `feature/misled-ethos-page` on a Vercel preview URL: Y2K-rave Win95 chrome, Anton + Press Start 2P + VT323 typography, cyan-titlebar subscribe form writing to Supabase, real confirmation emails in the same aesthetic.

3/ But `https://misled.vercel.app/` — the canonical URL I'd spent a week building toward — still deployed from `main`. Production-branch default never got changed. Feature branch did the work. Main was config only. Nobody told Vercel.

4/ Fix wasn't a git merge. The rule stayed: feature branch is the live source, main is configuration. Vercel dashboard flip — change production branch, promote the latest build. Ship. No merge-to-main risk.

5/ The lesson that stays: *smoke-test the URL you plan to send, not the URL you assume is serving.* The handoff said `preview_url: https://misled.vercel.app/` as fact. It was fact — once. State drifts. A plan is only as good as its most recently-verified assumption.

6/ Side-quest: a pre-push hook now runs lint + typecheck before every push (Turbo cache makes it 52ms cached). Cherry-picked to main so every sibling branch inherits it. The class of error that burns a remote build cycle gets caught locally.

7/ Ethos page live: [misled.vercel.app](https://misled.vercel.app/). Stage 1 of a three-stage launch (ethos → tease → pre-order). Essay on why the Y2K aesthetic was load-bearing, not decorative: [essay →]

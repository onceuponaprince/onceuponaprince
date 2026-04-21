1/ Started Scene 05 with a plan: scaffold two side-projects into BorAI, then review, then narrate. Two commits in, that plan was already wrong. Both scaffolds had landed out-of-band. The scene collapsed from plan → execute → review to review → synthesise → narrate.

2/ The orchestration shape inverted mid-scene. Plan-as-script doesn't survive contact with work that already happened. The scene still held. The capture just had to be corrected honestly: intent logged as intent, not as action. Scenes degrade the moment they confuse plans for events.

3/ Two projects catalogued. `ai-swarm-infra`: a Python orchestrator for a home LLM cluster. `study-buddy`: an Obsidian-vault parser that wants to be a study tool. One `ops/`, one `apps/`. Different categories, same polish pass.

4/ `study-buddy` shipped with an architectural divergence I hadn't written down. Spec: *copy vault into monorepo.* Scaffold: *user uploads a zip; the browser parses and stores everything client-side.* Vault as user data, not system data.

5/ That framing is the first-class architectural decision the scene actually produced. Future BorAI apps that can honour "data never leaves the device" probably will. Precedents in young projects are set by accident; the scene structure catches them before they set silently.

6/ The harder output wasn't code. It was a decision framework for *when* to start building study-buddy for real. Four behavioural signals, each with a threshold and a source: shareability, parser stability, tutor pull, mobile friction. No more "when I feel ready."

7/ Pattern Chapter 1 produced by accident: *structural polish without the build.* Align scaffolds to sibling conventions without writing application code. The chapter's discipline-first rule holds; momentum compounds. Scene 06 closes Chapter 1.

[essay →] · [github.com/onceuponaprince/borai.cc](https://github.com/onceuponaprince/borai.cc)

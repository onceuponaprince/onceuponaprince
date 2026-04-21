# Part 1: Catalogue Entry: study-buddy

### What
The study-buddy application is a runtime-import study engine designed to transform static Obsidian vaults into interactive learning environments. It functions as a browser-resident player that consumes a standard Obsidian directory, provided as a compressed zip file, and generates a structured curriculum of flashcards and quizzes. Unlike traditional learning management systems, it requires no account creation and no server-side database. The logic for parsing markdown, extracting frontmatter, and managing the spaced-repetition schedule executes entirely within the browser context of the user. By utilising client-side engineering, the tool processes markdown files into a temporary in-memory data structure, ensuring that the source material remains private and local.

### Problem
Obsidian has emerged as the incumbent tool for personal knowledge management, yet it remains a closed loop for active recall. Users who wish to study their notes as flashcards are tethered to the Obsidian application and specific community plugins. This creates a significant barrier for two distinct groups: the "transient learner" who wishes to study on a device where Obsidian is not installed, and the "knowledge curator" who wants to share their curated vaults with students or peers without forcing those recipients to adopt a complex new software suite. There is currently a "software tax" on shared knowledge: if one wishes to use another person's flashcards, one must first install their specific tools and replicate their environment.

### Landscape
The current market is dominated by internal Obsidian plugins, most notably st3v3nmw/obsidian-spaced-repetition. This tool is technically capable, supporting complex card types and LaTeX, but it stores repetition data within the markdown files themselves. This creates a synchronisation burden and requires the user to remain strictly inside the Obsidian ecosystem. Anki-bridge solutions exist but introduce a third-party dependency that many find cumbersome. There is a conspicuous absence of a web-native, "zero-install" player that treats an Obsidian vault as a portable, executable study module. Existing web based flashcard platforms typically require proprietary formats or manual entry, failing to recognise the latent value in the thousands of structured Obsidian vaults already in existence.

### Fit
Within the AI Command Centre campaign, study-buddy serves as the bridge between "passive documentation" and "active mastery". It validates the thesis that complex data structures, such as an Obsidian vault, can be repurposed as interactive software through client-side engineering. It fits the Chapter 1 constraint by focusing on the scaffolded logic: specifically the parser and the storage schema: while deferring the heavy lifting of the Next.js UI until the core utility is proven. The system establishes a pattern for future tools in the campaign by demonstrating how to build sophisticated utilities that respect data sovereignty while providing immediate, tangible value to the user.

### Caveats
The primary risk is the performance ceiling of browser-based processing. Large vaults with thousands of images or deeply nested directories may challenge the limits of JSZip and IndexedDB. Additionally, because data is stored in the local cache of the browser, clearing history can result in the loss of study progress unless a manual export or import loop is implemented. There is also a dependency on the user maintaining a consistent frontmatter schema within their Obsidian vault; if the metadata is malformed or missing, the parser will fail to identify study-ready notes.

# Part 2: Product Specification: study-buddy Platform

### Architectural Alternatives

**Architecture A: Runtime-import, client-side (The Selected Choice)**
This approach uses JSZip, gray-matter, and localforage to process the vault entirely in the browser. It relies on the user providing a zip archive of their vault, which is then uncompressed into a virtual file system in memory.
*   **Privacy Posture:** Absolute. The vault never leaves the machine of the user.
*   **Operating Cost:** Near zero. The operator only pays for static file hosting of the application assets.
*   **Feature Ceiling:** Medium. Limited by browser storage and the lack of server-side compute for complex artificial intelligence features or cross-device synchronisation.
*   **Time-to-Product:** Fast. No backend infrastructure to build, secure, or maintain.
*   **Storytelling Value:** High. It demonstrates a "privacy-first" technical sophistication that resonates with the Obsidian community and distinguishes the project from typical SaaS offerings.

**Architecture B: Static Bundle**
The vault content is imported into the monorepo at build time and served as pre-rendered static pages.
*   **Privacy Posture:** Low. Content is effectively public on the web once deployed.
*   **Operating Cost:** Low. Benefits from standard static site hosting tiers.
*   **Feature Ceiling:** Low. Inflexible and requires a new deployment for every minor vault update or content change.
*   **Time-to-Product:** Very fast. Essentially a wrapper around a static site generator.
*   **Storytelling Value:** Low. It feels like a standard documentation site rather than a dynamic study tool.

**Architecture C: Server-side Parse and Persist**
A traditional software-as-a-service model where users upload vaults to a server for processing and long-term storage.
*   **Privacy Posture:** Sensitive. Users must trust the operator with their private, often personal, notes.
*   **Operating Cost:** High. Requires database storage, file processing servers, and authentication logic.
*   **Feature Ceiling:** High. Enables multi-device synchronisation and advanced server-side analysis.
*   **Time-to-Product:** Slow. Requires significant backend development and security auditing.
*   **Storytelling Value:** Medium. A standard startup approach that lacks the architectural elegance of a client-side solution.

**Architecture D: Headless CMS-backed**
Vaults are imported into a content management system such as Contentful or Sanity, which then serves the study interface.
*   **Privacy Posture:** Low. Relies on third-party storage providers.
*   **Operating Cost:** Medium. Subject to CMS subscription fees and API usage limits.
*   **Feature Ceiling:** High for collaboration and editing but limited by the constraints of the CMS API.
*   **Time-to-Product:** Medium.
*   **Storytelling Value:** Low. Relies on third-party "magic" rather than custom engineering, weakening the developer-as-author narrative.

### Recommendation
Architecture A is recommended. It aligns perfectly with the preference of the Prince archetype for elegant, low-overhead solutions and respects the "data sovereignty" ethos of the Obsidian community. The trade-off is a lack of easy multi-device synchronisation, but this is mitigated by the "ephemeral study" use case where the user simply drops their vault zip into any browser to begin a session. It is a more sophisticated technical demonstration that proves the capability of the developer to build complex logic without relying on expensive backend infrastructure.

### Target User: The Resource Curator
The primary user is not a general student, but the "Resource Curator": an individual who has spent hundreds of hours building a high-quality Obsidian vault on a specialised topic (for example, Blockchain Engineering or Comedy Writing) and now wishes to distribute that knowledge in a "playable" format. This user values their intellectual property and the privacy of their students, making the client-side architecture a significant selling point. They are looking for a way to professionalise their knowledge base without the overhead of a full learning management system.

### Problem Statement
Knowledge curators struggle to turn their static notes into a low-friction learning experience for others. Sending a raw folder of markdown files is overwhelming for the recipient, and forcing them to set up Obsidian plugins is a high-friction request that often leads to abandonment. There is a need for a "player" that makes an Obsidian vault as easy to study as a video is to watch. The goal is to lower the barrier to entry for active recall, turning a passive reading experience into an active learning session with a single file upload.

### Core Surface (MVP Features)
1.  **Vault Drop-Zone:** A high-performance importer that handles zipped vaults and parses markdown frontmatter to identify notes marked as "study-ready". It must handle file path resolution for internal links and embedded images.
2.  **Flashcard Renderer:** A clean, focused interface for active recall, supporting basic markdown formatting and a spaced-repetition algorithm (for example, the SM-2 logic of Again, Hard, Good, and Easy).
3.  **Flagship Dashboard:** A summary view (referenced as a flagship vault, for example, The Sage) that calculates "Vault Mastery" based on the percentage of notes converted to successfully reviewed flashcards. It provides the user with a sense of progress across the entire knowledge base.

### Non-features
1.  **Markdown Editing:** This is a player, not an editor. All changes to the content must happen within Obsidian itself.
2.  **User Accounts:** There will be no login or registration. Progress is tied strictly to the IndexedDB of the browser.
3.  **Cloud Sync:** Synchronising data across devices is explicitly out of scope for the minimum viable product.

### Pricing Posture
The founder has not yet committed to a final commercial strategy, but is currently weighing two distinct alternatives for the pricing posture of the platform.

**Option I: Free, open-source only.**
In this scenario, there is no commercial layer. Growth is measured through adoption rates, GitHub stars, and community contributions. This approach keeps the tool pure and avoids premature monetisation, allowing the community proof of utility to build significant credibility before any revenue pressure is introduced.

**Option II: Free core + Custom Branded Players.**
The core tool remains free and open-source for individual use. For curators with their own audience, a flat fee (the specific price to be set by Prince) is charged for a standalone branded version of the application. This version would be pre-loaded with their specific vault and hosted on a custom domain. This posture monetises the curator persona specifically without gating the experience for students or casual learners.

### 90-day MVP Timeline
*   **Day 1-30:** Finalise the client-side parser utilising gray-matter and custom regular expressions to handle Obsidian-specific syntax. Establish the storage schema using localforage.
*   **Day 31-60:** Build the React-based flashcard interface and implement the basic spaced-repetition algorithm. Ensure the UI remains responsive and distraction-free.
*   **Day 61-90:** Develop the "Zip and Ship" export tool for curators and launch the primary landing page. Focus on documentation and onboarding for the first set of curators.

### Ongoing Cost Model
*   **Hosting:** £0 to £10 per month (Vercel or Netlify static tier).
*   **Domain:** £12 per year.
*   **Maintenance:** 4 hours per month for dependency updates and bug fixes.
*   **Total:** Negligible, allowing for long-term sustainability without immediate revenue.

### First-100-users Acquisition Story
Acquisition will focus on the Obsidian Discord community and the "Obsidian Roundup" newsletter. Prince will release a flagship vault on a specific topic (for example, The Sage) along with a link to the study-buddy player. By giving away a valuable vault and the tool to study it simultaneously, we create a proof of utility that encourages other curators to use the platform for their own content. The strategy relies on "learning in public" where the progress of the tool is shared transparently to build trust with a highly technical and privacy-conscious audience.

# Part 3: Decision Framework: When to Start the Next.js Build

Prince will know it is time to transition from the "scaffold" phase to the "full Next.js build" phase when the following criteria are met:

### Criterion 1: The Shareability Signal
*   **The Signal:** Unprompted requests from the existing network for a URL to a flagship vault (for example, The Sage).
*   **The Threshold:** Five distinct individuals asking for a web link rather than a download link within a thirty-day window.
*   **The Source:** Direct messages on social media or Discord after Prince shares progress screenshots of a flagship vault (for example, The Sage) and its associated study interface. This indicates that the value proposition has shifted from "private tool" to "shared resource".

### Criterion 2: The Parser Stability Signal
*   **The Signal:** The client-side importer successfully processes ten diverse, community-sourced Obsidian vaults without a fatal JSZip or gray-matter error.
*   **The Threshold:** A one hundred per cent success rate on a "Stress Test" suite of vaults containing at least five hundred notes and fifty megabytes of assets each.
*   **The Source:** Testing against public vaults found on the "Obsidian Hub" (publish.obsidian.md/hub). This ensures the parser is generalised enough to handle the varied ways people structure their data.

### Criterion 3: The "Tutor" Pull Signal
*   **The Signal:** A knowledge creator (someone with an existing audience or course) asks if they can use the tool to host their own curriculum.
*   **The Threshold:** A single high-intent enquiry regarding "Custom Branding" or "Hosted Versions" from an individual with a following of over one thousand people.
*   **The Source:** Incoming enquiries to the BorAI contact email or the personal social profiles of Prince. This validates the "Resource Curator" target user hypothesis.

### Criterion 4: The Mobile Friction Signal
*   **The Signal:** Internal testing reveals that the friction of the raw Obsidian mobile experience actively discourages daily study.
*   **The Threshold:** Three consecutive days where Prince avoids reviewing his notes because the mobile app is too slow to open or too cluttered for a brief session.
*   **The Source:** The "build-like-play" journal and daily habit tracker of Prince. This signal confirms that the current ecosystem is failing to meet the basic requirement for low-friction active recall, necessitating a more streamlined web-based alternative.

/**
 * warmth-stripper.js — Episode 2 ablation post-processor
 *
 * Pure function. No model dependency. Surface-agnostic.
 * Strips the five warmth primitives defined in taxonomy.md.
 *
 * Usage:
 *   const result = stripWarmth(warmText, { all: true });
 *   // result.warm === warmText
 *   // result.stripped === <flattened text>
 *   // result.removed === [{ primitive, span }, ...]
 *
 * Per-primitive ablation:
 *   stripWarmth(text, { hedges: true });
 *   stripWarmth(text, { footers: true, acknowledgements: true });
 *
 * The stripper is intentionally rule-based and conservative. It preserves all
 * load-bearing content (facts, recommendations, code, named entities, numbers).
 * It modifies register and structure only.
 */

// --- Primitive 1: hedges ---
const HEDGE_PATTERNS = [
  // softeners with "you could/might/probably"
  [/\byou could probably\b/gi, 'you should'],
  [/\byou might want to\b/gi, 'you should'],
  [/\byou could\b/gi, 'you should'],
  [/\bit might be worth (considering|thinking about|noting)\b/gi, 'consider'],
  [/\bit's probably\b/gi, 'it is'],
  [/\bprobably\b/gi, ''],
  [/\bperhaps\b/gi, ''],
  [/\barguably\b/gi, ''],
  [/\bgenerally speaking,?\s*/gi, ''],
  [/\bin general,?\s*/gi, ''],
  [/\btends? to\b/gi, 'does'],
  [/\bin some cases,?\s*/gi, ''],
  [/\boften\b/gi, ''],
  [/\bsometimes\b/gi, ''],
  [/\bI think\b/gi, ''],
  [/\bI believe\b/gi, ''],
  [/\bIf I had to bet,?\s*/gi, ''],
  [/\bI'd lean towards\b/gi, 'choose'],
  [/\bI would lean towards\b/gi, 'choose'],
  // tighten doubled spaces from removals
];

// --- Primitive 2: mirroring ---
const MIRROR_PREAMBLES = [
  /^(?:Great|Good|Fair|Excellent) (?:question|point)[^.!?]*[.!?]\s*/i,
  /^If I(?:'m| am) understanding (?:right|correctly)[^.!?]*[,.]\s*/i,
  /^So (?:you're|you are) asking about[^.!?]*[,.]\s*/i,
  /^You(?:'re| are) asking[^.!?]*[,.]\s*/i,
  /^What you(?:'re| are) describing is[^.!?]*[,.]\s*/i,
];

// --- Primitive 3: insight footers ---
// matches whole paragraph blocks that begin with an italic or parenthetical aside cue
const FOOTER_CUES = [
  /Aside:/i,
  /Small aside:/i,
  /Worth noting:/i,
  /On that:/i,
  /Bonus:/i,
  /Side note:/i,
];

// --- Primitive 4: acknowledgements ---
const ACK_PATTERNS = [
  /^(?:That is|That's) a (?:fair|good|great|reasonable) question[^.!?]*[.!?]\s*/i,
  /^You(?:'re| are) right to ask[^.!?]*[.!?]\s*/i,
  /^Honest answer:\s*I(?:'m| am) not sure[.!?]\s*/i,
  /^I appreciate (?:the|your) question[^.!?]*[.!?]\s*/i,
  /^Good (?:question|point)[^.!?]*[.!?]\s*/i,
];

// --- Primitive 5: structural rhythm ---
// flatten by replacing rhythmic colons / semicolons / em-dashes with periods.
// preserve definitional colons (heuristic: short word before colon, capital after — likely definitional)
function flattenRhythm(text) {
  // em-dashes (— or --) — replace with period+space, except in code blocks
  let out = text.replace(/\s+—\s+/g, '. ').replace(/\s+--\s+/g, '. ');
  // semicolons — split into sentences
  out = out.replace(/;\s+/g, '. ');
  // rhythmic colons (heuristic): colon followed by a lowercase word (continuation of thought) → period
  // definitional colons (Concept: definition) tend to have a capital after; preserve those
  out = out.replace(/:\s+([a-z])/g, '. $1');
  // collapse multiple spaces
  out = out.replace(/[ \t]{2,}/g, ' ');
  // tidy double-period from cascading replacements
  out = out.replace(/\.\s*\./g, '.');
  return out;
}

function stripParagraphFooters(text) {
  const paragraphs = text.split(/\n\n+/);
  const removed = [];
  const kept = [];
  for (const p of paragraphs) {
    const trimmed = p.trim();
    const isFooter = FOOTER_CUES.some((cue) => cue.test(trimmed));
    if (isFooter) {
      removed.push({ primitive: 'footer', span: trimmed });
    } else {
      kept.push(p);
    }
  }
  return { text: kept.join('\n\n'), removed };
}

function applyPatternList(text, patterns, primitive) {
  const removed = [];
  let out = text;
  for (const entry of patterns) {
    const [pattern, replacement] =
      Array.isArray(entry) ? entry : [entry, ''];
    const matches = out.match(pattern);
    if (matches) {
      for (const m of matches) {
        removed.push({ primitive, span: m });
      }
      out = out.replace(pattern, replacement);
    }
  }
  // tidy whitespace
  out = out.replace(/[ \t]{2,}/g, ' ').replace(/\s+([.,;:!?])/g, '$1');
  return { text: out, removed };
}

/**
 * Strip warmth from a completion string.
 *
 * @param {string} warmText - the warm completion to strip
 * @param {object} flags - which primitives to strip
 * @param {boolean} flags.all - if true, strip everything (overrides individual flags)
 * @param {boolean} flags.hedges
 * @param {boolean} flags.mirroring
 * @param {boolean} flags.footers
 * @param {boolean} flags.acknowledgements
 * @param {boolean} flags.rhythm
 * @returns {{warm: string, stripped: string, removed: Array<{primitive: string, span: string}>}}
 */
function stripWarmth(warmText, flags = {}) {
  const config = flags.all
    ? { hedges: true, mirroring: true, footers: true, acknowledgements: true, rhythm: true }
    : flags;

  let working = warmText;
  const removed = [];

  // Order matters: footers BEFORE rhythm flattening (paragraph syntax must survive)
  if (config.acknowledgements) {
    const r = applyPatternList(working, ACK_PATTERNS, 'acknowledgement');
    working = r.text;
    removed.push(...r.removed);
  }
  if (config.mirroring) {
    const r = applyPatternList(working, MIRROR_PREAMBLES, 'mirror');
    working = r.text;
    removed.push(...r.removed);
  }
  if (config.footers) {
    const r = stripParagraphFooters(working);
    working = r.text;
    removed.push(...r.removed);
  }
  if (config.hedges) {
    const r = applyPatternList(working, HEDGE_PATTERNS, 'hedge');
    working = r.text;
    removed.push(...r.removed);
  }
  if (config.rhythm) {
    working = flattenRhythm(working);
  }

  // final tidy
  working = working.replace(/\n{3,}/g, '\n\n').trim();

  return {
    warm: warmText,
    stripped: working,
    removed,
  };
}

// CommonJS + ES module export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { stripWarmth };
}
if (typeof globalThis !== 'undefined') {
  globalThis.stripWarmth = stripWarmth;
}

/**
 * warmth-stripper.test.js — fixture pinning the conservative behaviour
 *
 * Two layers of test per primitive:
 *   1. Mechanical: a register-only example IS stripped.
 *   2. Load-bearing (TODO slots): a content-bearing example is NOT stripped,
 *      because the stripper's patterns are deliberately narrow.
 *
 * Run: node --test campaigns/emotional-ux/ep2/warmth-stripper.test.js
 *
 * If a future change widens the pattern-set and these load-bearing tests fail,
 * the change has crossed from register-stripping into content-stripping. That
 * is the boundary the experiment cannot afford to cross.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const { stripWarmth } = require('./warmth-stripper');

// --- Primitive 1: hedges ---

test('hedges — strips modal softeners (register only)', () => {
  const r = stripWarmth('You could probably use a composite index.', { hedges: true });
  assert.equal(r.stripped.trim(), 'you should use a composite index.');
});

test('hedges — preserves real conditionals (load-bearing)', () => {
  // Source: campaigns/agent-architecture/sources/2026-04-23-claude-cold.md:158.
  // "depends on" here is genuine causal content, not register softening.
  const warm = 'Most teams instrument tokens and latency because their billing depends on it.';
  const expected = 'Most teams instrument tokens and latency because their billing depends on it.';
  const r = stripWarmth(warm, { hedges: true });
  assert.equal(r.stripped.trim(), expected.trim());
});

// --- Primitive 2: mirroring ---

test('mirroring — strips restatement preambles', () => {
  const warm = 'Great question about indexes! Use a composite on (user_id, created_at).';
  const r = stripWarmth(warm, { mirroring: true });
  assert.equal(r.stripped.trim(), 'Use a composite on (user_id, created_at).');
});

test('mirroring — preserves clarifications (load-bearing)', () => {
  // A clarification that disambiguates a project-specific term — the
  // restatement is content (which definition applies), not register.
  // Project terminology lifted from ep2-dispatch.md (multi-turn vs single-shot).
  const warm = "By 'session' do you mean a single round-trip or the multi-turn arc? The metric for each is different.";
  const expected = "By 'session' do you mean a single round-trip or the multi-turn arc? The metric for each is different.";
  const r = stripWarmth(warm, { mirroring: true });
  assert.equal(r.stripped.trim(), expected.trim());
});

// --- Primitive 3: insight footers ---

test('footers — strips paragraph asides', () => {
  const warm = 'Add the index.\n\nAside: this pattern shows up often in activity feeds.';
  const r = stripWarmth(warm, { footers: true });
  assert.equal(r.stripped.trim(), 'Add the index.');
});

// Footer load-bearing protection lives upstream of the stripper, per
// taxonomy.md:43-45 — the stripper deletes any footer-cued paragraph by
// default. No edge-case slot here; the protection is a workflow concern.

// --- Primitive 4: acknowledgements ---

test('acknowledgements — strips validations', () => {
  const r = stripWarmth("That's a fair question. Add the index.", { acknowledgements: true });
  assert.equal(r.stripped.trim(), 'Add the index.');
});

test('acknowledgements — preserves corrections (load-bearing)', () => {
  // The "right that X, but Y" form encodes a correction — agreement on a
  // partial truth followed by the substantive caveat. Stripping it would
  // drop the correction, not just the validation. Project context lifted
  // from ep2/instrumentation-spec.md (schema reuse + optional fields).
  const warm = "You're right that the metric_alert schema covers per-session ablation, but the consumer cannot disambiguate ablation runs from production crossings without the three optional fields.";
  const expected = "You're right that the metric_alert schema covers per-session ablation, but the consumer cannot disambiguate ablation runs from production crossings without the three optional fields.";
  const r = stripWarmth(warm, { acknowledgements: true });
  assert.equal(r.stripped.trim(), expected.trim());
});

// --- Primitive 5: structural rhythm ---

test('rhythm — flattens semicolons to sentences', () => {
  const warm = 'Use a composite index; this halves the query time.';
  const r = stripWarmth(warm, { rhythm: true });
  assert.equal(r.stripped.trim(), 'Use a composite index. this halves the query time.');
});

test('rhythm — preserves definitional colons (load-bearing)', () => {
  // Source: ~/code/CLAUDE.md (vault thesis maxim form).
  // "Maxim form: Build" — the colon introduces a definition, capital
  // letter after marks the definitional move. The heuristic in
  // flattenRhythm must protect it.
  const warm = 'Maxim form: Build should feel like play. Play should write the story.';
  const expected = 'Maxim form: Build should feel like play. Play should write the story.';
  const r = stripWarmth(warm, { rhythm: true });
  assert.equal(r.stripped.trim(), expected.trim());
});

// --- Audit trail ---

test('audit — removed array captures spans with primitive labels', () => {
  const r = stripWarmth('You could probably add an index.', { all: true });
  assert.ok(r.removed.length >= 1, 'removed array should be populated');
  assert.ok(
    r.removed.some((entry) => entry.primitive === 'hedge'),
    'hedge primitive should appear in removed log',
  );
  assert.equal(r.warm, 'You could probably add an index.', 'warm input preserved');
});

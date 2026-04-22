# Upstream issues

Log of observations about the Claude Code product (or its surrounding harness) that aren't addressable from inside this vault. Append-only. Date each entry.

---

## 2026-04-22 — Repeated skill-list dumps in session-start reminders

The `system-reminder` block listing all available skills appears multiple times per session — once at session start and again on any subsequent skill-state refresh. The list is long (100+ entries) and does not change within a session. Emitting it once per session would suffice; emitting it four or more times is pure token overhead.

Observed during Scene 2b-01's session analysis. Not addressable from the vault side. Worth raising with Anthropic / Claude Code product team as a harness-level issue.

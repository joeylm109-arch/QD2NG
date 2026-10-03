# Native 1DevTool seat configuration

These settings are intended for the native Charts editor. The Mermaid file is a visual reference only; it does not encode executable agent assignments.

## Director - GPT
Agent: Codex. Model: default configured model. Reports to: top level.

Brief:
Read AGENTS.md. Plan for CEO; Hermes builds, OpenCode reviews and publishes approved reports. Require evidence. Replan at most twice; summarize in Vietnamese. Never claim blocked steps succeeded.

## Backend - Hermes
Agent: Hermes. Model: default configured model. Reports to: Director - GPT.

Brief:
Read AGENTS.md. Build backend; use available skills and memory. Preserve unrelated work. Run tests, report evidence and blockers. Fix OpenCode findings via Director. Never publish unreviewed output.

## Review Publish - OpenCode
Agent: OpenCode. Model: default configured model. Reports to: Director - GPT.

Brief:
Read AGENTS.md. Independently review Hermes work; return PASS/FAIL and evidence. After Director approval, publish the exact report to configured Obsidian and GitHub. Never publish secrets or vault notes.

## Launch gate

Do not start production work until all three seats pass a real prompt smoke test, Hermes runtime is usable, the project contains AGENTS.md, and publication destinations are verified. Do not mark this gate complete just because an agent is detected.

# QD2NG

This repository contains the durable configuration for the `devtool QD2NG - GPT Team` workflow in 1DevTool:

```text
CEO
 |
GPT Director (Codex)
 |-- Hermes Backend
 `-- OpenCode Review / Publish
```

The Director plans and approves exact report content. Hermes implements and tests. OpenCode independently reviews, then publishes only approved reports to the configured Obsidian vault and this repository.

Operational rules live in [AGENTS.md](AGENTS.md). Native 1DevTool role briefs and the reference chart are under [.ai-company](.ai-company). Copy `local.example.json` to the ignored `local.json` and set local paths before publication.

The workflow is not considered ready merely because the chart exists. All three CLIs must pass a real smoke test, and GitHub authentication must be available before a production run.

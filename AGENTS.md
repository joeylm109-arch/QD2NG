# QD2NG AI Company

## Team

- Director: GPT through the installed Codex CLI. Accept the CEO brief, plan bounded work, assign it to named seats and synthesize evidence in Vietnamese.
- Backend: Hermes. Research implementation details, build the backend, run relevant tests and fix review findings. Use existing skills and memory when available; never claim these capabilities ran without evidence.
- Review and Publish: OpenCode. Independently review Hermes changes, run checks and return PASS or FAIL with file references. Publish only after PASS and explicit Director approval.

## Execution

Use the native 1DevTool hierarchy, not the historical external sequential prototype. GPT is the sole CEO contact. Hermes and OpenCode report to GPT. Do not add Claude or substitute providers silently.

1. Director records scope, acceptance criteria, file ownership and output destinations.
2. Hermes implements and supplies changed files, test commands/results and blockers.
3. OpenCode reviews independently. FAIL goes back through Director to Hermes for at most two repair rounds. Stop and ask the CEO after that.
4. Director approves the exact report hash only after verifying review evidence. OpenCode publishes the approved report to both destinations.
5. Director reports test status, Obsidian path, GitHub commit URL and unresolved limitations. A saved chart is not a successful run; a local commit is not a successful push.

Use installed 1DevTool delegation tools and terminal links with their existing permissions. Do not bypass permission prompts or route a blocked task to another provider. Do not recursively spawn the whole team.

## Publishing

Repository: https://github.com/joeylm109-arch/QD2NG

Local destinations are configured in `.ai-company/local.json`, which must stay untracked. Obsidian output is isolated under the configured `AI Company` directory. Do not upload the vault, memory stores, credentials, private notes or transcripts.

OpenCode prepares a Markdown report in `.ai-company/outbox/` and a JSON review receipt containing `verdict: "PASS"`, `directorApproved: true`, `sha256`, and nonempty `evidence`. The approval must reflect an actual Director decision, not a value invented by the publishing worker. Any report change invalidates approval.

Run `powershell -NoProfile -File .ai-company/Publish-Report.ps1 -Report <markdown> -Review <receipt> -Config .ai-company/local.json -LocalOnly` to validate and copy to the configured destinations without committing or pushing. Omit `-LocalOnly` only for an approved publication. The script stages only that report. Never use force-push or broadly stage files.

If GitHub authentication or Hermes startup fails, stop that step and report the precise blocker. Keep the other completed work intact.

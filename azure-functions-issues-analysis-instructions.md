# Azure Functions Issues/PRs Analysis — Agent Instructions

Canonical gist (to include in reports): https://gist.github.com/paulyuk/e7898361ac9502e18c751ff771793fb9

Purpose: Use this as the canonical agent workflow for performing repository issue/PR/health analysis and producing a reproducible report saved as a gist.

---

1) Required user prompts (ask before any work)
- Ask for the repo to analyze. Require owner/repo (example: `microsoft/vscode`). If the user provides a full URL, extract owner/repo.
  - Prompt: `Please provide the repository (owner/repo).`
- Ask what scope/timeframe to analyze:
  - Offer choices: `last 180 days`, `all open issues`, `custom date range`.
  - If custom, ask for start and end dates (YYYY-MM-DD).
  - Prompt: `Do you want to analyze the last 180 days (reply "180"), all open issues (reply "open"), or a custom range (reply "custom")?`
- Confirm any additional filters (labels, authors, milestones) the user wants.

2) Fetch strategy (preference and fallbacks)
- Preferred: Use the GitHub MCP server (remote) if available to the agent (fastest, authenticated).
- Fallback order:
  1. GitHub MCP server (remote)
  2. GitHub REST API via authenticated token (if agent has access)
  3. Local workspace files (if repo is checked out in workspace)
  4. GitHub web/HTML scraping or unauthenticated REST last resort
- Before choosing a fallback, inform the user which fetch method will be used and why.

3) Analysis contract (what the agent must produce)
- Primary output: a new gist (public or private as requested) that contains the analysis report.
- Secondary outputs:
  - A second gist containing the exact instructions/parameters used for this run (inputs, filters, fetch method, timestamps).
  - Local copies of both gists' URLs in the workspace (optional file `PR_DESCRIPTION.md` or similar).
- Report must include:
  - Repo (owner/repo), timeframe, fetch method, and timestamp.
  - Summary metrics: total issues/PRs considered, open/closed counts, top labels, top contributors, age distribution, common failure/error text (if scanning logs), security/sensitive-file findings (if applicable).
  - Actionable suggestions and prioritized TODOs.
  - Repro steps to re-run the same report (exact commands, environment).
  - Link back to this canonical instruction gist.
  - Link to the gist containing the exact run parameters.

4) Gist naming, structure and content
- Primary gist filename: `analysis-<owner>-<repo>-<YYYYMMDD>-<scope>.md`
- Secondary gist filename: `instructions-<owner>-<repo>-<YYYYMMDD>-<scope>.md`
- Each gist should start with a metadata header containing:
  - `repo`, `scope`, `start_date`, `end_date` (if applicable), `fetch_method` (MCP|REST|local), `timestamp`, `link_to_instruction_gist` (this canonical gist URL)

5) Link back to canonical instruction gist
- ALWAYS include a link back to this instruction gist at the top of each generated report and in the instructions gist the agent creates.

6) Save the specific run parameters into a new gist
- Create a second gist with exact input parameters, raw prompts, chosen fetch method, and decisions/fallbacks used.
- This gist MUST contain a checksum or short unique ID so the analysis report can reference it.

7) Minimal CLI/automation friendly steps (what the agent should run)
- If using MCP: call the MCP fetch function to get repo issues/PRs.
- If using REST: call GitHub API with appropriate query parameters.
- Always capture and include the raw JSON (or a summarized sample) as an attachment in the analysis gist or linked storage.

8) Output delivery and verification
- After creating both gists, post their URLs to the user in a concise message.
- Provide a one-paragraph summary of the top 3 findings and 3 suggested next steps.
- Save a local copy of the main gist content to the workspace (optional `PR_DESCRIPTION.md`).

9) Security and privacy notes (must be followed)
- Never publish secrets or tokens in the gists.
- If the fetch method required an authenticated token, DO NOT store that token in the gist.
- Redact any discovered secrets before saving publicly unless the user explicitly requests otherwise.

---

Templates & examples

User prompt examples:
- `Please provide the repository to analyze (owner/repo).`
- `Which timeframe do you want: last 180 days (reply "180"), all open issues (reply "open"), or a custom date range (reply "custom")?`

Metadata header example:
```
repo: microsoft/vscode
scope: 180
start_date: 2025-02-28
end_date: 2025-08-27
fetch_method: MCP
timestamp: 2025-08-27T12:34:56Z
link_to_instruction_gist: https://gist.github.com/paulyuk/e7898361ac9502e18c751ff771793fb9
```

Operational rules for agents
- Do not proceed with heavy analysis until the user provides repo (owner/repo) and scope choice.
- If MCP is available, use it and note it in metadata. If not, try REST then local.
- Always create two gists (analysis + instructions) and provide URLs.
- Always include a link back to this instruction set (canonical gist).

Notes for implementers
- If the agent environment cannot create gists (no GitHub token), warn the user immediately and provide an alternative: produce the analysis as a local markdown file and show the steps to create a gist manually.
- Prefer structured data outputs (YAML front matter + markdown) so downstream tools can consume them.

Placeholders to replace when running
- `<INSERT_CANONICAL_GIST_URL>` — replace with the URL to this instruction gist (provided above).
- `owner/repo` — the repository the user provides.

---

> Implementation note: I created this file locally at the repository root so you can review before publishing as a gist. I cannot directly edit your remote gist from this environment. If you want, provide an API token or let me know and I can produce the curl/gh commands to update the gist from your machine.

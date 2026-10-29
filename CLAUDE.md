# CLAUDE.md

## Project context
This repo documents Adedapo's AZ-104 (Microsoft Azure Administrator) hands-on build: a fictional company, Contoso, built across five connected projects plus a bonus. The full plan and checklists live in `docs/PROJECT_GUIDE.md`. Read it before helping with any project.

## Goals
1. Pass the AZ-104 exam (skills measured as of April 17, 2026).
2. Produce portfolio material: per-project READMEs, scripts, diagrams, LinkedIn posts, resume bullets.

## Background
Adedapo holds AWS Solutions Architect Associate and Security+. When explaining Azure concepts, map them to AWS equivalents where useful.

## Conventions
- Naming: `<type>-contoso-<purpose>`; storage accounts `stcontoso<purpose><4 chars>`.
- Regions: East US 2 (primary), Central US (secondary). Nothing else.
- Tags on every resource group: env, owner, project, costcenter.
- Infrastructure as code: Bicep preferred, Azure CLI for one-off commands.
- Screenshots: `projects/<NN-name>/screenshots/PP-SS-description.png`.

## How to help
- For code (Bicep, CLI, KQL, scripts): give a skeleton with TODOs first. Give the full version only when asked.
- Every deploy script needs a matching teardown script in `teardown/`.
- Keep costs low: smallest VM sizes, and remind about deleting Bastion, load balancers, and Site Recovery replication after each session.
- When updating a project README, use the template in section B3 of the guide and fill the break/fix log from what Adedapo reports.
- Resume bullets and LinkedIn drafts live outside this repo in `~/Documents/Career/AZ-104 Portfolio/`, never in the repo. Each project README gets a Summary section instead.
- When drafting LinkedIn posts, use the template in section B6. Do not use em dashes in any written content.
- Tie explanations back to the specific AZ-104 objective being practiced and add a line to `docs/exam-notes.md` when a new takeaway comes up.

## Never
- Never commit secrets: passwords, storage keys, SAS tokens, connection strings, tenant or subscription IDs. Use parameters, `@secure()`, and `.gitignore`.
- Never hardcode Adedapo's real email or IP addresses in committed files.

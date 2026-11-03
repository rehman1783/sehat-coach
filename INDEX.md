# Sehat Coach — delivery control index

Status: Planning baseline established 18 October 2026  
Current delivery state: **Local implementation and verification in progress; production integration and external acceptance pending.** See the module control board for current evidence. Percentages previously discussed are planning estimates, not measured release acceptance.

This file is the starting point for product, design, implementation, review, and acceptance. It follows the same evidence-driven workflow used for the CRM project: requirements are traced, work is divided into bounded modules, generated implementation is reviewed against explicit gates, and completion is recorded only after verification.

## Control documents

| Document | Purpose |
|---|---|
| [Product charter](docs/00-product-charter.md) | Product boundaries, users, outcomes, and non-negotiables |
| [Repository baseline](docs/01-current-state-audit.md) | What exists today, what is prototype-only, and known defects |
| [Delivery operating model](docs/02-delivery-operating-model.md) | Codex/Antigravity workflow, status vocabulary, evidence, and change control |
| [Module roadmap](docs/03-module-roadmap.md) | Ordered implementation modules and their dependency gates |
| [Module control board](docs/04-module-control-board.md) | Live status, entry/exit gates, and acceptance ownership |
| [UI/UX strategy](docs/05-ui-ux-strategy.md) | How Figma references become a reusable Flutter design system |
| [Quality and release gates](docs/06-quality-release-gates.md) | Test layers, security/safety checks, and definition of done |
| [Strategy source set](docs/strategy/README.md) | Detailed traceability, architecture, phased backlog, and open decisions |
| [Handoff protocol](docs/handoffs/README.md) | Format for bounded Antigravity prompts and Codex review reports |
| [Architecture decisions](docs/decisions/ADR-001-local-database.md) | Accepted technical decisions, evidence, constraints, and remaining gates |

## Source of truth hierarchy

1. Latest explicit product-owner decision.
2. Requirements traceability matrix and approved decision register.
3. Module specification and acceptance criteria.
4. UI/UX strategy and approved screen states.
5. Code and tests.
6. Figma exports and generated prototype code as visual reference only.

If two sources conflict, implementation stops at the narrow conflict, the conflict is recorded, and the higher source wins after owner confirmation. A visual mockup never silently changes a safety, privacy, or product rule.

## Immediate next gate

Continue the remaining V1 integration and feature work from the module control board. Firebase/Gemini remain the documented target architecture. Live integration requires development project configuration; clinical activation, licensed data, store products and Android acceptance retain their recorded gates. M07 AI assistance and M08 monetization are in local implementation and must not be represented as live services.

## Development numbering

- `V1` identifies the approved first product release.
- `M01`, `M02`, and so on identify ordered development modules within that release.
- A smaller bounded implementation uses a suffix such as `V1-M03-S01`.
- Corrections found during review use a revision such as `V1-M03-R01`.
- Evidence, commits, branches, handoffs, reviews, and status updates should include the applicable identifier.
- V2 work starts a separate sequence: `V2-M01`, `V2-M02`, and so on.

## Status vocabulary

- **Not started** — no accepted implementation evidence.
- **Prototype present** — exploratory UI/code exists but is not architecture- or acceptance-compliant.
- **Ready for implementation** — dependencies and acceptance criteria are resolved.
- **In implementation** — bounded module is being changed.
- **Ready for review** — implementer supplied code, tests, and evidence.
- **Verified locally** — Codex review and available automated checks passed.
- **External acceptance pending** — clinical, legal, security, device, or owner approval remains.
- **Complete** — every exit gate passed and evidence is linked.


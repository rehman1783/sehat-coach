# Delivery operating model

## Roles

- **Product owner:** approves scope, claims, commercial rules, and unresolved decisions.
- **Codex:** owns planning artifacts, bounded implementation prompts, code review, corrective edits when requested, verification, and evidence-based status.
- **Antigravity/implementer:** implements only the active module prompt, documents deviations, and returns test/evidence output.
- **Qualified reviewer:** approves clinically consequential rules and warning language.
- **Security/privacy/legal reviewers:** approve their respective launch gates.

## Module cycle

1. **Prepare:** confirm dependencies, decision IDs, requirement IDs, designs, threat cases, and acceptance tests.
2. **Prompt:** Codex writes one bounded handoff with allowed files, prohibited shortcuts, migrations, tests, and evidence.
3. **Implement:** Antigravity changes only the stated module and reports assumptions/deviations.
4. **Review:** Codex inspects the actual diff and maps behavior to requirements; implementer claims are not accepted on trust.
5. **Verify:** run formatting, static analysis, tests, migrations, device checks, and applicable security/safety cases.
6. **Correct:** fix or return a precise defect list; rerun affected gates.
7. **Accept:** owner/external reviewer approval is recorded where required.
8. **Close:** update the control board and traceability evidence, then prepare the next module.

## Development identifier format

Every delivery artifact uses `V{release}-M{module}`. For example, `V1-M03` means release V1, module 03. Use `-S01` for a bounded slice and `-R01` for a review correction. This identifier belongs in the handoff title, branch/commit description, review report, test evidence, and control-board entry.

## Change-control rule

New ideas are classified before implementation:

- **Clarification:** improves wording without changing behavior; update the module spec.
- **Correction:** resolves mismatch with an already approved requirement; implement within the current module if safe.
- **Scope change:** alters behavior, data, safety, cost, or schedule; record a decision and re-sequence affected modules.
- **Future feature:** add to the roadmap without destabilizing the active module.

## Review severity

- **P0:** data loss, account leakage, dangerous advice, secret exposure, or release-blocking security issue.
- **P1:** incorrect core behavior, broken sync/migration, inaccessible critical flow, or material requirement gap.
- **P2:** maintainability, performance, resilience, or secondary UX defect.
- **P3:** polish or low-risk consistency improvement.

P0/P1 issues block module completion. P2 issues require an owner and due module. P3 issues may enter the polish backlog.

## Required evidence packet

Every module review must include:

- commit/diff or exact changed-file list;
- requirement and decision IDs addressed;
- architecture/data-model notes and migration impact;
- commands run with results;
- screenshots for affected responsive states;
- offline, error, loading, empty, permission-denied, and accessibility states where relevant;
- security/privacy/safety cases relevant to the change;
- known limitations and deferred items.

## Prohibited shortcuts

- Marking a screen complete without its error/offline/accessibility states.
- Putting clinical, price, entitlement, or safety truth only in client code.
- Bypassing repositories to access persistence directly from widgets.
- Silently deleting pending records during sign-out, migration, or conflict handling.
- Treating generated Figma code as production Flutter architecture.
- Enabling clinically consequential output before reviewer approval.


# V1-M07 AI coaching and assisted logging

## Current evidence — 25 October 2026

The first backend-neutral safety boundary and GetX review flow are implemented locally. AI meal logging requires explicit consent, sends a bounded request carrying locale and owner/request identity, and accepts only versioned proposals with schema, prompt and model provenance. Every successful proposal remains a review step: the user must explicitly choose candidates before anything can become a meal record. The UI provides Roman Urdu/English selection, visible assumptions, per-candidate selection and a permanent manual-search route.

Expired, request-mismatched, low-confidence and provider-failed proposals return a private manual-search fallback. Consent denial never calls the provider. The contract intentionally contains no client API key and no direct Gemini invocation; the trusted Firebase Functions/Cloud Run backend remains responsible for token verification, App Check, quotas, prompt selection, model access and audit metadata.

Confirmed candidates can now be resolved by exact approved catalog food and serving IDs into the existing unsaved meal draft. Resolution is all-or-nothing: a missing food, invalid serving, duplicate suggestion or catalog failure leaves the draft untouched and sends the user to manual review. Nutrition continues to come from the deterministic catalog calculator, and this handoff never saves a meal automatically.

When that reviewed draft is eventually saved, its immutable event and sync payload can carry the AI request ID, schema/prompt/model versions, proposal and confirmation timestamps, and the accepted catalog/serving/quantity/confidence matches. Provider output is retained only as audit provenance; authoritative nutrient values still come from the separately versioned catalog calculation. Manual meals retain a null provenance field. Encrypted Drift schema v14 adds this backward-compatible optional value.

The trusted-backend client adapter is also implemented. It accepts only an HTTPS endpoint supplied through the non-secret `AI_BACKEND_URL` compile-time setting, obtains fresh Firebase ID and App Check tokens through injected platform boundaries, sends bounded JSON, enforces request identity and a 256 KiB response limit, and strictly decodes the versioned proposal. It contains no Gemini credential or direct provider URL. Server HTTP failures and malformed responses fail closed; HTTP 429 exposes only the backend-provided retry time and does not calculate or mint quota locally.

An authenticated, owner-bound AI credit-reservation client now exists under M08, but it is not independently chained to the proposal call. The production backend must reserve and then settle or release credits atomically with provider execution so network interruption cannot strand client-orchestrated reservations. Until that server workflow is deployed, the AI preview remains non-metered local integration evidence rather than an activated paid service.

Focused tests cover consent denial, explicit confirmation, expiry, low confidence, request binding, provider failure, malformed payload rejection, exact catalog handoff and no-partial-mutation failures. Static analysis is clean.

## Remaining acceptance work

- Implement and deploy the Firebase Functions/Cloud Run endpoint, token/App Check verification and Gemini provider call.
- Build and approve the versioned prompt registry, Urdu/Roman Urdu evaluation set, safety evaluation and cost/rate limits.
- Define server retention/redaction policy for AI request metadata and verify it in the Firebase transport.
- Add voice/photo transport only after privacy retention and consent behavior are approved.
- Complete clinical/privacy acceptance before enabling consequential recommendations.

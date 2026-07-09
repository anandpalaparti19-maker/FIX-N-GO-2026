Fix-N-Go — Production Readiness Audit
Codebase reviewed: FIX-N-GO-2026-main (uploaded ZIP) — backend (Node/Express/MongoDB), customer_app & technician_app (Flutter), admin_panel (React/Vite), infrastructure (Docker, Mosquitto, Nginx).
Prepared for: Anandd  |  Date: July 9, 2026

1. Executive Summary
Fix-N-Go is architecturally sound and further along than a typical portfolio project — proper JWT auth with refresh-token rotation, helmet/CORS/rate-limiting, Mongo sanitization, atomic first-accept-wins dispatch, Sentry, structured logging, and a real Jest test suite (auth, dispatch, booking e2e, orders, payment, wallet) are all in place. That said, the audit surfaced one critical, systemic issue and several high-severity gaps that would cause real financial and security problems in production.
The single most important finding: the app has two payment gateways wired into two different screens for what is effectively the same 'pay for completed job' moment, and only one of them actually credits the technician's wallet and platform ledger. If the code path customers actually hit in normal use is the one that doesn't credit the ledger, technicians can be paid by the customer and never receive their payout in-app. This alone should block a production launch until resolved.
Severity
Count
Theme
CRITICAL
2
Payment/wallet crediting gap; path traversal in file uploads
HIGH
6
Route mismatches, Aadhaar/bank data stored in plaintext, weak webhook signature verification, mis-targeted env validation, OTP logged in plaintext
MEDIUM
6
Job-count counted at accept not completion, broken cash-payment mock flow, missing password strength check, minor race conditions
LOW / POLISH
5+
Dead Stripe code, thin Flutter test coverage, stray build artifacts and backup folders in the repo

2. What's Already Solid
JWT auth (authMiddleware.js) verifies tokens correctly, refuses to boot without JWT_SECRET, and doesn't fall back to a weak default.
Refresh tokens are revocation-tracked and rotated atomically (findOneAndUpdate with revoked flag) — protects against replay of a stolen refresh token.
validateEnv.js refuses to start in production with weak/default JWT secrets, which is a genuinely good practice most portfolio projects skip.
Atomic first-accept-wins dispatch (acceptOrder) uses a single findOneAndUpdate with a status/dispatchStatus guard — this correctly prevents two technicians from accepting the same job.
Password reset flow correctly avoids user-enumeration (always returns success, never reveals whether the email exists).
Global + per-route + per-user rate limiting is layered sensibly (IP-based global, stricter on /api/auth, per-user token bucket elsewhere).
A real backend test suite exists (~1,000 lines across auth, dispatch, booking e2e, orders, payment, wallet) — this is above what most solo projects have at this stage.
3. Critical Findings
3.1 Two payment gateways, only one completes the money flow
This is the most important issue in the codebase.
What happens today, traced end-to-end:
When a technician marks a job complete via OTP (completeOrder in orderController.js), the backend creates a Razorpay order and pushes a checkoutSession to the customer over MQTT.
track_technician_screen.dart listens for that notification and opens the native Razorpay checkout (razorpay_flutter is wired up correctly here).
Separately, order_detail_screen.dart and payment_sheet.dart call a completely different pair of endpoints — /api/payments/create-intent and /api/payments/confirm — which talk to Cashfree, not Razorpay.
Only the Razorpay path credits money anywhere: webhookController.js verifies the Razorpay webhook signature and, in a Mongo transaction, credits the technician's wallet, records the WalletTransaction, and writes the PlatformLedger commission split.
The Cashfree path (paymentController.confirmPayment) only flips payment.status and order.paymentStatus to 'captured'. It never touches WalletTransaction, PlatformLedger, or the technician's technicianMeta.walletBalance.
Net effect: if a customer ever completes payment through the Cashfree screen (order_detail_screen / payment_sheet), the money is captured but the technician's wallet is never credited and no commission is recorded — silently. There is also no reconciliation job to catch this drift later.
Compounding evidence this is unfinished rather than intentional:
validateEnv.js requires STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET to be set in production — but handleStripeWebhook is a two-line stub that just returns { received: true } and does nothing. Meanwhile CASHFREE_APP_ID/SECRET and RAZORPAY_KEY_ID/SECRET/WEBHOOK_SECRET — the gateways actually used — aren't validated at all. Production could boot with real payment credentials completely missing.
confirmCashPayment in payment_service.dart fabricates a fake cashfreeOrderId ('cf_test_cash_...') for cash-on-delivery jobs, but paymentController.confirmPayment strictly requires payment.cashfreeOrderId === cashfreeOrderId from a real Cashfree order created earlier — so this fake ID will not match and the cash-payment flow will reject with 'Invalid payment order ID'. Cash payments look broken end-to-end.
Recommendation: Pick one gateway as canonical for the 'pay after completion' step (Razorpay is further along — it already has correct wallet crediting via webhook). Either delete the Cashfree create-intent/confirm endpoints and screens, or move the wallet/ledger crediting logic out of the webhook and into a single shared service function called by whichever gateway actually confirms payment, then call it from both places. Remove the Stripe stub and its env requirements entirely. Add a nightly reconciliation script that flags any order with paymentStatus='captured' but no matching WalletTransaction.
3.2 Path traversal in photo/KYC upload filenames
In photoRoutes.js and technicianProfileRoutes.js, multer's filename callback builds the on-disk filename directly from the client-supplied name:
filename: (req, file, cb) => { cb(null, `${Date.now()}_${file.originalname}`); }
photoController.js repeats the same pattern when moving the file into its final location. Because file.originalname is attacker-controlled and is never passed through path.basename() or sanitized, a filename like ../../../../some/path/evil.png could write outside the intended uploads/temp directory. The multer fileFilter only checks MIME type (client-supplied, spoofable) and, in one route, file extension — neither prevents directory traversal in the name itself.
Recommendation: Never use file.originalname in a path. Generate the on-disk name yourself, e.g. `${crypto.randomUUID()}${path.extname(file.originalname)}`, and validate that extname is in an allowlist after stripping any path separators.
4. High-Severity Findings
#
Severity
Area
Finding
1
HIGH
Routes
Flutter's payment_service.dart calls POST /api/payments/withdraw and GET /api/payments/withdraw/history. Neither exists — withdrawal is actually mounted at POST /api/wallet/withdraw, and there is no withdrawal-history endpoint anywhere in the backend. Withdrawal requests and history from the app will 404.
2
HIGH
Data protection
Aadhaar numbers and bank account/IFSC details (technicianModel.js) are stored as plain strings with no field-level encryption. This is sensitive government-ID and financial data; storing it in plaintext is a real compliance and breach-impact concern for an India-based fintech-adjacent product.
3
HIGH
Webhook security
razorpayWebhook falls back to a hardcoded default secret ('rzp_test_webhook_secret') if RAZORPAY_WEBHOOK_SECRET isn't set — if that env var is ever missing in production, anyone who knows this (now-public, since it's in the code) string can forge a valid wallet-crediting webhook call. Also, the signature is computed via crypto.createHmac(...).update(JSON.stringify(req.body)) — re-serializing the parsed body doesn't guarantee byte-identical output to what Razorpay originally signed (key order, spacing), which can cause legitimate webhooks to fail verification intermittently. Use the raw request body (express.raw + a verify callback) for HMAC checks, the same way the Stripe route already does.
4
HIGH
Env validation
validateEnv.js's production checklist requires Stripe keys (unused) and omits Cashfree/Razorpay keys (used for all real money movement) — the exact opposite of what's needed. The server can pass startup validation while being unable to process a single real payment or wallet payout.
5
HIGH
Logging / PII
authController.sendPhoneOtp logs the OTP value in plaintext: logger.info(`OTP sent to ${phone}: ${otp}`). Anyone with log access (Sentry breadcrumbs, log files, a misconfigured log drain) can take over any account mid-verification.
6
HIGH
Data integrity
acceptOrder increments technicianMeta.jobsDone at acceptance, not at completion. A job that's later cancelled still counts toward the technician's lifetime job count, inflating a number likely shown to customers as a trust signal.

5. Medium-Severity Findings
#
Severity
Area
Finding
7
MEDIUM
Auth
registerUser never enforces a minimum password length (resetPassword does — >= 6 chars — but the primary signup path doesn't check at all).
8
MEDIUM
Payments
Cash-on-delivery confirmation flow is broken end-to-end (see 3.1) — a customer choosing 'pay with cash' will likely get an error trying to close out the order.
9
MEDIUM
Concurrency
acceptOrder checks 'do I already have an active job' in a separate query before the atomic findOneAndUpdate — a technician tapping accept on two jobs in quick succession could theoretically slip through both checks before either write commits.
10
MEDIUM
Duplicate accounts
verifyPhoneOtp checks for an existing phone with a raw, non-normalized lookup (User.findOne({ phone })), while email lookups are carefully normalized/escaped elsewhere — phone numbers entered with different formatting (spaces, +91 prefix) could create duplicate accounts.
11
MEDIUM
Repo hygiene
The uploaded archive contains lib_backup_20260604_124037/ (a full duplicate of the Flutter lib folder), a build_locked_... Android build-artifacts folder, cloudflared.exe, and a scratch/ folder — these bloat the repo, risk stale code being edited by mistake, and shouldn't ship to a production branch.
12
MEDIUM
Withdrawal amount
walletController.submitPayout is called with the raw, unvalidated req.body.amount rather than the already-validated parsedAmount — inconsistent but currently harmless since parsedAmount gated the transaction; still worth tightening so both paths always agree on the same validated number.

6. Low Severity / Polish
handleStripeWebhook and its route (/api/payments/webhook) are dead code that does nothing but return 200 — remove it, or actually finish it if Stripe is meant to be a real third option.
razorpay.js and paymentController.js both default to hardcoded 'dummy'/'test' key strings when env vars are missing, rather than failing loudly — combined with the env-validation gap in 3.1/4, this makes it easy to deploy with no working payment gateway and not notice until a real customer tries to pay.
Flutter test coverage is thin — customer_app and technician_app each have only the default widget_test.dart plus one auth_provider_test.dart; there's no test coverage for payment_service.dart, order_detail_screen.dart, or the dispatch/tracking screens, which are exactly the areas with the bugs above.
getMonthlyEarnings in paymentController.js is a stub that always returns an empty array — the technician earnings-by-month UI has no real data behind it yet.
getTechnicianEarnings reads req.user.totalEarnings, but wallet crediting elsewhere writes to technicianMeta.totalEarnings — check this field-path mismatch; if confirmed, technician earnings summaries will always show 0.
7. Prioritized Fix Roadmap
Before any real-money pilot (block launch on these)
1. Collapse to a single payment gateway for the post-completion charge; make sure wallet/ledger crediting happens on every successful payment through one shared, tested code path. Add a reconciliation check.
2. Fix the withdrawal route mismatch (/api/payments/withdraw → /api/wallet/withdraw) and add the missing withdrawal-history endpoint.
3. Sanitize/replace file.originalname in every multer filename callback (photoRoutes.js, technicianProfileRoutes.js) to close the path-traversal gap.
4. Fix validateEnv.js to require the gateway keys actually in use (Cashfree and/or Razorpay + webhook secret) instead of Stripe.
5. Remove the OTP-value log line in sendPhoneOtp.
6. Switch the Razorpay webhook signature check to use the raw request body, and remove the hardcoded fallback webhook secret.
Before wider production rollout
7. Encrypt Aadhaar and bank account fields at rest (field-level encryption or a KMS-backed encrypted-string type), or at minimum mask them in every API response and admin view.
8. Move jobsDone increment from acceptOrder to completeOrder.
9. Enforce a minimum password length/strength on registerUser.
10. Normalize phone numbers the same way emails are normalized before duplicate checks.
11. Fix or intentionally remove the broken cash-payment confirmation path.
Cleanup / polish
12. Delete lib_backup_*, build_locked_*, scratch/, and cloudflared.exe from the repo (or move them out of the tracked tree); add them to .gitignore.
13. Remove the dead Stripe webhook stub and its dependency, or build it out properly if it's meant to be a real gateway.
14. Add Flutter widget/unit tests around payment_service.dart and the two payment screens, since that's where the highest-impact bugs live.
15. Implement getMonthlyEarnings and verify the totalEarnings vs technicianMeta.totalEarnings field-path consistency.
8. Closing Note
None of this changes the overall assessment that Fix-N-Go is a genuinely strong portfolio piece — the dispatch atomicity, refresh-token handling, and layered rate limiting are the kind of details many production apps get wrong. The payment/wallet gap in section 3.1 is the one item that would actually lose someone money if it shipped as-is, so it's worth treating as the true 'done' gate before calling this production-ready, ahead of everything else in this report.
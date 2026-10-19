# Xplor Pay Mobile EMV (IDTech VP3300) — Integration Guide

Implementation of Xplor Pay (formerly Clearent) Mobile EMV payments in this
Flutter app using the IDTech VP3300 Bluetooth reader, wrapped with a Flutter
platform channel.

## Architecture

```
Flutter (Dart)                                iOS (Objective-C)
-----------                                   -----------------
XplorPayTerminalView (demo screen), XplorPayTapToPayView
  └─ XplorPayTerminalController (GetX)
       ├─ XplorPayService ──── MethodChannel "xplorpay/methods"
       │      │                EventChannel  "xplorpay/events"
       │      └──────────────► XplorPayPlugin.m
       │                          ├─ Clearent_VP3300 (initWithConnectionHandling:)
       │                          ├─ ClearentManualEntry (fallback)
       │                          └─ delegates → event sink (main thread)
       └─ XplorPayApiClient ───► POST /rest/v2/mobile/transactions/sale
              headers: api-key, mobilejwt
```

### Files

| Layer | File | Purpose |
|---|---|---|
| Native | `ios/Podfile` | Adds `ClearentIdtechIOSFrameworkPod` 4.0.182 |
| Native | `ios/Runner/XplorPayPlugin.h/.m` | Flutter channels + SDK delegates |
| Native | `ios/Runner/AppDelegate.swift` | Registers XplorPayPlugin |
| Native | `ios/Runner/Runner-Bridging-Header.h` | Exposes plugin to Swift |
| Native | `ios/Runner/Info.plist` | NSBluetoothAlwaysUsageDescription |
| Native | `ios/Flutter/Debug.xcconfig`, `Release.xcconfig` | `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES` (the pod's umbrella includes `<IDTech/IDTech.h>`; without this the app build fails) |
| Native | `ios/Runner.xcodeproj/project.pbxproj` | Plugin files added to target |
| Dart | `lib/app/services/xplorpay/xplorpay_service.dart` | Channel wrapper + mock |
| Dart | `lib/app/services/xplorpay/xplorpay_event.dart` | Typed event stream |
| Dart | `lib/app/services/xplorpay/xplorpay_models.dart` | Sale request/result models |
| Dart | `lib/app/services/xplorpay/xplorpay_api_client.dart` | Submits the JWT to the gateway |
| Dart | `lib/app/modules/xplorpay/` | Terminal demo screen (view + GetX controller + binding) |
| Dart | `lib/app/routes/app_routes.dart`, `app_pages.dart` | Route `/xplorpay-terminal` |

## Setup checklist (manual steps)

Everything code-wise is committed; these are the steps a human must do:

1. **Pods** — already installed (`pod install` was run against the Podfile
   entry). If you ever hit "sandbox is not in sync", just run:
   ```bash
   cd ios && pod install
   ```
2. **CocoaPods trunk** — the pod is NOT on trunk. The Podfile pins the
   podspec URL at tag `4.0.182` of `xplor-pay/ClearentIdtechIOSFrameworkPod`.
   To upgrade, bump the tag in `ios/Podfile` and re-run `pod install`.
3. **Xcode signing** — open `ios/Runner.xcworkspace` (not .xcodeproj), select
   the Runner target → Signing & Capabilities → your team. The plugin and pod
   are already wired into the project file.
4. **Credentials** — baked in as static test credentials in
   `lib/app/services/xplorpay/xplorpay_credentials.dart` (user decision, so
   no on-device entry is needed). The screens only let you pick the gateway
   environment (Production / Sandbox INT). Before production, move the
   api-key behind your own backend — see "Security notes".
5. **Hardware** — charge and power on the VP3300; enable Bluetooth on the
   iPhone. The reader pairs automatically (flashing green middle LED).
6. **Build/run on a physical iPhone** — the simulator has no Bluetooth and
   the real `XplorPayService` is iOS-only; on the simulator and on Android
   the app falls back to `MockXplorPayService` automatically.
7. **Reaching the screen** — navigate to `/xplorpay-terminal`, e.g. from a
   debug menu:
   ```dart
   Get.toNamed(Routes.XPLORPAY_TERMINAL);
   ```

## Test plan (physical iPhone + VP3300)

| # | Scenario | Steps | Expected |
|---|---|---|---|
| 1 | Connect | Enter keys → Save → Connect reader | LED flashes green; app shows Connected; feedback shows BT messages |
| 2 | Successful sale | Connect → enter `1.00` → Charge card → insert chip card | Feedback sequence (CARD INSERTED → CARD READ OK → GOING ONLINE → CARD SECURED) → APPROVED with auth code + txn id |
| 3 | Declined card | Repeat 2 with a card known to decline | Gateway returns `result: DECLINED` → DECLINED banner, display-message shown |
| 4 | Reader disconnect mid-transaction | Start charge, then power off reader | `disconnected` event → state resets to idle with "disconnected mid-transaction" |
| 5 | Bluetooth off | Disable BT, tap Connect reader | 20s timeout message; no crash |
| 6 | Reader timeout | Start charge, don't present card | Reader TIMEOUT feedback → error event → UI resets |
| 7 | Cancel | Start charge → Cancel | `device_cancelTransaction` → idle; reader returns to ready |
| 8 | Manual entry | Expand manual section → type test card → submit | Token arrives → gateway submission (sandbox test card) |
| 9 | Double-tap guards | Tap Charge repeatedly | No duplicate transactions; button disabled while busy |
| 10 | Background/foreground | Background app mid-transaction, return | Connection events re-fire; state stays consistent |

## Assumptions & unverified details

Verified against the framework headers (tag 4.0.182) — NOT assumptions:
delegate method names, `ClearentPayment` properties (`amount` double,
`amtOther`, `type` int, `timeout`, `tags`, `fallback`, `forceOnline`),
`ClearentVP3300Config` properties, connection initializers, `startConnection:`,
`startTransaction:clearentConnection:`, `device_cancelTransaction`,
`device_disconnectBLE`, token fields (`jwt`, `cvm`, `lastFour`, `cardType`),
feedback (`message`, `feedBackMessageType`, `returnCode`).

Assumptions still worth double-checking:

1. **Gateway base URLs** — `https://gateway.clearent.net` (prod) and
   `https://gateway-int.clearent.net` (sandbox) came from the docs AI-search
   endpoint referencing the Getting Started page. Confirm in your Xplor Pay
   onboarding docs. (The OpenAPI spec itself ships no servers block.)
2. **Response envelope** — the parser accepts the transaction object at the
   root OR under `transaction`, plus `errorResults` for 4xx/402. The spec
   shows a bare `transaction` schema for 200; historical Clearent APIs
   sometimes wrap. Adjust `XplorPayTransactionResult.fromGatewayJson` if your
   responses differ.
3. **Transaction `type` on ClearentPayment = 0** — docs say 0 = Sale; there
   is no enum header for it. Confirmed only by doc examples.
4. **`device_cancelTransaction` vs `emv_/ctls_cancelTransaction`** — header
   says device_cancel cancels "swipe or CTLS"; if chip cancels feel incomplete
   in testing, also call `emv_cancelTransaction`.
5. **The JWT is single-use** and expires quickly (per docs "include the
   token... while submitting"). The app submits immediately upon receipt.
6. **Manual entry** uses `ClearentManualEntry init:clearentBaseUrl:publicKey:`
   — must be enabled for your merchant account before it will tokenize.
7. **Request body fields** are all strings per the spec (`amount: "10.00"`),
   which the code follows.

## Security notes

- No keys were hardcoded historically; as of 2026-10-14 the TEST api-key
  and public key ARE compiled in via `xplorpay_credentials.dart` (user
  decision for field testing). Replace with a backend-issued token before
  production — production credentials must never ship in the binary. The demo screen stores them in
  SharedPreferences for field convenience only.
- **Recommended production flow**: point the client at your own backend.
  `XplorPayApiClient.submitSaleJwt(baseUrl:...)` already accepts any base URL —
  host an endpoint on your server that receives `{jwt, amount, ...}`,
  injects the `api-key` server-side, and calls
  `/rest/v2/mobile/transactions/sale`. Then the device never holds the
  API key, and `mobilejwt` still travels from the device to your backend.
- The JWT never appears in logs: `DioClient` uses PrettyDioLogger with
  `requestHeader: false`, and the native plugin never NSLogs card data or
  tokens.
- The reader keeps card data off the app entirely — the app only ever sees
  the encrypted token.

## Tap to Pay on iPhone (Apple Proximity Reader)

Contactless payments directly on a supported iPhone — no external reader. The
SDK (`ClearentUIManager`) owns the entire flow: Apple's tap sheet,
tokenization, and sale processing. Entry point: `/xplorpay-tap-to-pay`.

### Architecture additions

| Layer | File | Purpose |
|---|---|---|
| Native | `ios/Runner/XplorPayTapToPayPlugin.swift` | Swift plugin (channels `xplorpay/tap_to_pay` + `xplorpay/tap_to_pay/events`). Swift — not Obj-C — because the Tap to Pay API (`ClearentUIManager`, `PaymentInfo`, `TapToPayDeviceSupportResult`) is only in the framework's Swift module interface; the generated Obj-C header does not declare it (verified at tag 4.0.182). |
| Native | `ios/Runner/AppDelegate.swift` | Registers both plugins |
| Native | `ios/Runner/Runner.entitlements` | Proximity Reader entitlement — **not wired into signing yet** (see below) |
| Dart | `lib/app/services/xplorpay/xplorpay_tap_to_pay_service.dart` | Platform interface + real + mock |
| Dart | `lib/app/modules/xplorpay/` (tap to pay controller/view/binding) | Screen at `/xplorpay-tap-to-pay` |

Sale outcomes reach Dart through `ClearentWrapper.shared.delegate`
(`didFinishTransaction`), because the `tapToPayViewController` completion only
signals UI dismissal, not the sale verdict (per docs).

### Manual steps (a human must do these)

1. **Apple Developer Program approval** — request the "Proximity Reader
   Payment Acceptance" capability for the App ID. Without it, Tap to Pay
   cannot work on any device.
2. **Attach the entitlement** after approval:
   `ios/Runner/Runner.entitlements` already contains
   `com.apple.developer.proximity-reader.payment.acceptance`. Wire it in Xcode
   (Runner target > Signing & Capabilities) or set
   `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`. Deliberately not
   pre-wired: until Apple approves, referencing the entitlement breaks
   device-build signing (VP3300 testing would also stop working).
3. **Physical iPhone only** — iPhone XR or newer, iOS 15.4+, passcode
   enabled, NFC on. `verifySupport` surfaces each of these failures with
   Apple's message.

### Credentials

Static test credentials live in
`lib/app/services/xplorpay/xplorpay_credentials.dart` (api-key + public key,
compiled into the app so the screens need no on-device entry). Only the
gateway environment (Production / Sandbox INT) is selectable on the screens.
These are TEST credentials — never ship production keys this way; move the
api-key server-side before production (see "Security notes").

### Test plan (after Apple approval)

| # | Scenario | Steps | Expected |
|---|---|---|---|
| 1 | Unsupported device | Open screen on simulator / old iPhone | "Tap to Pay unavailable" with Apple's reason |
| 2 | Missing entitlement | Run before step 2 above | `verifySupport` reports the missing-entitlement message |
| 3 | Terms linking | "Accept Apple terms" | Apple terms sheet; status flips to accepted |
| 4 | Prepare | "Prepare" (or just charge) | Reader session pre-warms; status "prepared" |
| 5 | Successful sale | Enter amount -> "Charge with Tap to Pay" | Apple tap sheet -> hold card -> APPROVED banner with txn id |
| 6 | Declined | Repeat with declining card | SDK error screen -> `transaction` event with error/declined |
| 7 | Cancel | Back out of Apple tap sheet | `closed` event; UI resets |
| 8 | Backgrounding | Background app mid-checkout, return | SDK re-prepares automatically (docs behavior) |

### Notes

- **Entitlement probe deferred**: the Swift plugin's `verifySupport` runs the
  hardware-only check. The completion variant (which also probes the
  entitlement through ProximityReader's `readerIdentifier`) is deliberately
  NOT called until Apple approves the capability — observed on a real device
  (iOS 27, 4.0.182): calling it without the entitlement — or before
  `initialize` — traps inside the SDK (EXC_BREAKPOINT). Same reason the
  account-linked status is only refreshed from the terms-linking flow, never
  on screen load. The TODO(entitlement) comment in
  `XplorPayTapToPayPlugin.swift` marks the line to restore.
- The SDK fetches the reader session JWT itself
  (`/rest/v2/mobilejwt/apple/taptopay/session`) and submits the sale itself
  (`/rest/v2/mobile/transactions/sale`) — the app never handles the
  Tap to Pay card token.
- `TransactionResponse` is opaque (Codable, hidden fields); Dart parses it
  leniently via the same `fromGatewayJson` used for VP3300 and keeps the raw
  payload for diagnostics. Verify field extraction on a real approval and
  adjust if needed.
- After a terminal profile change, the screen can be extended with
  `forceRefreshToken: true` on prepare (docs: only after profile changes).

## Android

Out of scope for this pass. The Dart interface is platform-agnostic: on
non-iOS platforms the controller automatically uses `MockXplorPayService`.
For a real Android implementation later, add
`android/app/src/main/.../XplorPayPlugin.kt` registering the same
`xplorpay/methods` + `xplorpay/events` channels and the same event contract
(see `xplorpay_event.dart`), using the Android IDTech SDK
(github.com/clearent/android-idtech-sdk). No Dart changes required.

## Where the SDK contract came from

- Framework headers downloaded from
  `xplor-pay/ClearentIdtechIOSFrameworkPod` tag `4.0.182` (the docs' Carthage
  instructions are outdated — the `Clearent/iOS-framework` repo is gone).
- API contract from the OpenAPI spec embedded at
  docs.xplorpay.com/api-reference/api/payments/mobile/mobile-payment-transactions/
  (`api-key` + `mobilejwt` headers; `ClearentGatewayRequest` body).
- Gateway env URLs from the docs search endpoint (see assumptions).

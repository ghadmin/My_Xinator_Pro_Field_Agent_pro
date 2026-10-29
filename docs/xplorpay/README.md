# Xplor Pay Mobile EMV (IDTech VP3300) — Integration Guide

Implementation of Xplor Pay (formerly Clearent) Mobile EMV payments in this
Flutter app using the IDTech VP3300 Bluetooth reader, wrapped with a Flutter
platform channel.

## Architecture

```
Flutter (Dart)                                iOS (Objective-C)
-----------                                   -----------------
XplorPayTerminalView (demo screen)
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
4. **Credentials** — obtain from your Xplor Pay onboarding:
   - `publicKey` (SDK encryption; environment-specific)
   - `api-key` (gateway REST calls; environment-specific)
   Enter them on the terminal screen (they persist in SharedPreferences) or
   see "Security notes" for the recommended production flow.
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

- No keys are hardcoded anywhere in the repo. The demo screen stores them in
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

## Tap to Pay on iPhone (Apple ProximityReader)

Reader-free contactless payments on top of the same Clearent framework,
bridged inline (no package dependency — the standalone
`xplor_pay_tap_to_pay` package keeps an identical copy for other apps).

### Files

| Layer | File | Purpose |
|---|---|---|
| Native | `ios/Podfile` | Same `ClearentIdtechIOSFrameworkPod` 4.0.182 pin (Tap to Pay ships inside it) |
| Native | `ios/Runner/XplorPayTapToPayPlugin.swift` | Channels `com.xceleran.tapToPay/tap_to_pay` + `/events`; must be Swift (the Obj-C bridging header omits the whole Tap to Pay API) |
| Native | `ios/Runner/Runner.entitlements` | `com.apple.developer.proximity-reader.payment.acceptance` (dotted — per Apple's ProximityReader setup guide; requires the capability enabled on the App ID) |
| Native | `ios/Runner.xcodeproj/project.pbxproj` | Plugin file + `CODE_SIGN_ENTITLEMENTS` on the Runner target |
| Native | `ios/Runner/AppDelegate.swift` | Registers both XplorPay plugins |
| Dart | `lib/app/services/xplorpay/xplorpay_tap_to_pay_service.dart` | Channel wrapper, verdict model, gateway-error enrichment |
| Dart | `lib/app/services/xplorpay/xplorpay_credentials.dart` | Compiled-in TEST keys (sandbox INT); replace with a backend proxy before production |
| Dart | `lib/app/modules/xplorpay/` | Tap to Pay screen (view + controller), invoice recorder shared with the terminal screen |
| Dart | `payment_method_selection_view.dart` | Adds "Card Reader (VP3300)" + "Tap to Pay on iPhone" entries (iOS only) |

### Flow (matches the SDK docs)

initialize → verifyTapToPayDeviceSupport(completion) → linkAccount (once, if
Apple's terms are unaccepted) → prepareTapToPay (pre-warm) →
tapToPayViewController(paymentInfo). The controller completion is UI-dismiss
only; the sale verdict comes from `ClearentWrapper`'s
`didFinishTransaction` and is delivered to Dart exactly once. Abandoned
checkout calls `invalidateTapToPaySession()`; a successful sale never does.

### Gotchas encoded in the code

- Calling `verifyTapToPayDeviceSupport(completion:)` before `initialize`
  traps inside the SDK — the plugin guards it and returns
  "SDK is not initialized".
- The SDK is `@MainActor`; every bridge handler is annotated accordingly
  (required on Xcode 26 / Swift 6 toolchains even in Swift 5 mode).
- ClearentError exposes only `type` — errors are surfaced to Dart as
  `type` + `gateway` (`localizedDescription (resultCode: N)`); e.g.
  `missingData` (9) = the Tap to Pay session-token endpoint returned no token.
- Apple reader sessions do not survive backgrounding; the SDK re-prepares
  automatically, and `forceRefreshToken` is reserved for terminal-profile
  changes.

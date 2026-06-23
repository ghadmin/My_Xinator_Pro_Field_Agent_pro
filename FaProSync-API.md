# FaProSync API — Mobile Developer Spec

> **Audience:** Fa Pro mobile app developer
> **Server side:** FSM (`testsite.myserviceforce.com/fsm/`)
> **Endpoint:** `FaProSync.ashx`
> **Status:** Phase 3 shipped, verified end-to-end on 2026-04-28
> **Version:** 1.0

---

## Table of contents

1. [TL;DR — what the app does](#tldr)
2. [Authentication](#authentication)
3. [Base URL](#base-url)
4. [Endpoint: `op=poll`](#endpoint-oppoll)
5. [Endpoint: `op=ack`](#endpoint-opack)
6. [Endpoint: `op=submit`](#endpoint-opsubmit)
7. [The form structure (template) explained](#the-form-structure-template-explained)
8. [Field types — value shape reference](#field-types--value-shape-reference)
9. [Smart fields — all sources](#smart-fields--all-sources)
10. [Downloading the source PDF](#downloading-the-source-pdf)
11. [HTTP status codes & errors](#http-status-codes--errors)
12. [Retry & idempotency rules](#retry--idempotency-rules)
13. [Polling cadence recommendation](#polling-cadence-recommendation)
14. [Local development setup](#local-development-setup)
15. [Known issues & roadmap](#known-issues--roadmap)
16. [Appendix A — full real example (PDF template with smart fields)](#appendix-a--full-real-example-pdf-template-with-smart-fields)
17. [Appendix B — full real example (PDF template with parts table)](#appendix-b--full-real-example-pdf-template-with-parts-table)

---

## TL;DR

Three endpoints, one base URL, one API key:

| Op | Method | What the app does |
|---|---|---|
| `poll` | GET | "Any new forms for me?" — returns pending forms with full schema + prefilled smart fields |
| `ack` | POST | "Got 'em, downloaded, working offline now." — server stops re-pushing them |
| `submit` | POST | "Tech finished, here are the answers + signatures." — server stamps PDF, emails customer if configured |

The flow on the phone:

```
APP STARTS
  ↓
poll every 30s while online
  ↓
new items? → for each item:
  • parse template.structure (JSON string)
  • download PDF if mode==="pdf"  (URL = baseUrl + pdfFile.path)
  • cache locally
  ↓
ack the queueIds you've cached
  ↓
TECH FILLS FORM (online or offline)
  ↓
submit → server stamps PDF + emails customer (if configured)
```

That's it. Read the rest for the detail you need to actually implement it.

---

## Authentication

Every request needs the API key. Two ways to send it:

**Preferred — HTTP header:**
```
X-Api-Key: fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5
```

**Fallback — query string** (don't use in production logs):
```
?apiKey=fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5
```

If the key is missing or wrong, the response is **HTTP 401**:
```json
{ "success": false, "error": "Unauthorized" }
```

> ⚠️ **MVP:** there is currently **one API key shared across all companies**. Future versions will switch to per-company keys, but the API contract won't change — you'll still send it as `X-Api-Key`.

> 🔒 **Don't commit the key to your app's source control.** Inject it at build time, or ship a "first launch" config screen where the company admin pastes it in. Treat it like a password.

---

## Base URL

| Environment | URL |
|---|---|
| Production | `https://testsite.myserviceforce.com/fsm/FaProSync.ashx` |
| Local dev (when FSM is running on a dev machine) | `http://localhost:62934/FaProSync.ashx` |

Build the full URL by concatenating: `{baseUrl}/FaProSync.ashx?op={op}&...`

For PDF file downloads (see [§10](#downloading-the-source-pdf)) and stamped-PDF viewing, the base URL is `https://testsite.myserviceforce.com/fsm/` (no `FaProSync.ashx` suffix).

---

## Endpoint: `op=poll`

**Method:** `GET`
**URL:** `{baseUrl}/FaProSync.ashx?op=poll&companyId={X}&resourceId={Y}`
**Headers:** `X-Api-Key: {apiKey}`

### Query parameters

| Name | Type | Required | Notes |
|---|---|---|---|
| `op` | string | yes | Must be `poll` |
| `companyId` | string | yes | The company's identifier (e.g. `msProDemo1`). Stored on the device once at login/setup. |
| `resourceId` | int | yes | The technician's resource ID in FSM. Stored on the device once at login/setup. |

### Example request

```bash
curl "https://testsite.myserviceforce.com/fsm/FaProSync.ashx?op=poll&companyId=msProDemo1&resourceId=2444" \
  -H "X-Api-Key: fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5"
```

### Example response (200 OK)

```json
{
  "success": true,
  "count": 1,
  "items": [
    {
      "queueId": 1,
      "formInstanceId": 260,
      "appointmentId": "197",
      "templateId": 56,
      "resourceId": 2444,
      "action": "Push",
      "triggerId": 3,
      "createdDateTime": "2026-04-27T15:39:45",
      "customerId": "47",
      "instanceStatus": "Pending",
      "sendToCustomerOnSubmit": false,
      "template": {
        "id": 56,
        "name": "Field Service Report",
        "description": "",
        "structure": "{\"version\":\"4.0\",\"mode\":\"pdf\",\"pdfFile\":{...},\"fields\":[...]}",
        "requireSignature": false,
        "requireTip": false
      },
      "smartFieldData": "{\"pdf_1776367292253_hpb9ud\":\"John Smith\",\"pdf_1776367962325_m4i3fa\":\"Acme HVAC Ltd\"}"
    }
  ]
}
```

### Field reference

| Field | Type | Meaning |
|---|---|---|
| `queueId` | int | The queue row ID. **Use this in `op=ack` and `op=submit`.** |
| `formInstanceId` | int | The FormInstance ID (the actual form-fill record). Used in `op=submit`. |
| `appointmentId` | string | FSM appointment ID. Pass through to `op=submit`. |
| `templateId` | int | Form template ID. Pass through to `op=submit`. |
| `resourceId` | int / null | Target tech. NULL means "any tech in this company can pick it up". |
| `action` | string | `Push` (new form) or `Cancel` (admin removed; v1 you can ignore Cancel — Phase 5). |
| `triggerId` | int / null | Audit trail — which trigger rule fired this. Display in debug only. |
| `createdDateTime` | ISO 8601 string | When the trigger fired server-side. |
| `customerId` | string | The customer attached to the appointment. Pass through to `op=submit`. |
| `instanceStatus` | string | `Pending` for forms not yet submitted, `Submitted` for forms already pushed back via `op=submit`. **Mobile client should dedupe and skip / show-as-submitted accordingly.** |
| `sendToCustomerOnSubmit` | bool | If true, server will email the stamped PDF to the customer when you submit. Display "📧 Will email customer" badge if you want; otherwise just pass through. |
| `template.id` / `name` / `description` | — | Display title in the inbox UI. |
| `template.structure` | JSON **string** | Parse with `JSON.parse()` to get the form schema. See [§7](#the-form-structure-template-explained). |
| `template.requireSignature` | bool | If true, the form-builder marked at least one signature field as required. (Field-level `required` is the source of truth — this is just a header hint.) |
| `template.requireTip` | bool | If true, prompt the tech for a tip amount on submit. (Future feature; v1 you can ignore.) |
| `smartFieldData` | JSON **string** | Parse with `JSON.parse()` to get a map `{ fieldId: prefillValue }`. Use these as the **default values** for smart-field inputs. The tech can override. |

### Edge cases

- **No forms for this resource:** `count: 0, items: []`. Still HTTP 200.
- **Wrong companyId:** Returns `count: 0` (no error — companyId can't be authenticated yet, so unknown company looks the same as no work).
- **Wrong resourceId:** Same — empty result.
- **Smart-field resolution failure:** `smartFieldData` falls back to `"{}"`. The poll itself still succeeds. Tech will need to type the smart-field values manually.
- **Already-Acked / Already-Submitted forms reappearing:** **By design.** Poll no longer filters on queue Status. The same form will be returned on every poll until the underlying `FormInstance` is hard-deleted. Mobile client uses `formInstanceId` to dedupe locally and `instanceStatus` to decide whether to show it as fillable or as submitted history. This change (2026-05-23) replaces the previous Pending-only filter, which broke multi-device scenarios — once one device Acked, the second device for the same resource would never see the form.

---

## Endpoint: `op=ack`

**Method:** `POST`
**URL:** `{baseUrl}/FaProSync.ashx?op=ack`
**Headers:** `X-Api-Key: {apiKey}`, `Content-Type: application/json`

Records that this device has successfully downloaded the listed queue items. The queue rows flip to `Status='Acked'`, `AckedDateTime` is stamped, and the linked FormInstances get `IsSynced=1`.

> **Note (2026-05-23):** Acking no longer hides the form from subsequent polls — the same form will keep coming back until its FormInstance is deleted or its `instanceStatus` becomes `Submitted`. Ack now functions purely as an audit/sync marker. Call it once after persisting locally; you don't need to track or re-call on later polls.

### Request body

```json
{
  "companyId": "msProDemo1",
  "queueIds": [1, 2, 3],
  "deviceInfo": "iPhone 15 Pro / iOS 18.2 / TechApp 2.4.1"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `companyId` | string | yes | Same value as poll. Used to scope the ack so a malicious request can't ack another company's queue. |
| `queueIds` | int array | yes | The `queueId` values from the poll response. Array can have 1+ items. Empty → 400. |
| `deviceInfo` | string | no | Free-form. Stored in `FaProSyncQueue.AckedDeviceInfo` for audit. Recommended: model + OS version + app version. |

### Example request

```bash
curl -X POST "https://testsite.myserviceforce.com/fsm/FaProSync.ashx?op=ack" \
  -H "X-Api-Key: fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5" \
  -H "Content-Type: application/json" \
  -d '{
    "companyId": "msProDemo1",
    "queueIds": [1],
    "deviceInfo": "iPhone 15 Pro / iOS 18.2 / TechApp 2.4.1"
  }'
```

### Example response (200 OK)

```json
{
  "success": true,
  "acked": [1],
  "requested": 1
}
```

| Field | Meaning |
|---|---|
| `acked` | The queueIds that successfully flipped Pending → Acked. Already-Acked rows or rows belonging to a different company are silently dropped from this list. |
| `requested` | How many you sent. Compare with `acked.length` to see if any were rejected. |

### Edge cases

- **Already acked:** Idempotent. Second call returns `acked: []` for those IDs, no error. **Safe to retry on network failure.**
- **Wrong companyId:** Silent skip — that queueId is omitted from `acked`. Cannot ack another company's items.
- **Empty `queueIds` array:** HTTP 400 `"queueIds must be a non-empty array"`.

---

## Endpoint: `op=submit`

**Method:** `POST`
**URL:** `{baseUrl}/FaProSync.ashx?op=submit`
**Headers:** `X-Api-Key: {apiKey}`, `Content-Type: application/json`

The big one. Tech finished filling, push it back. The server:

1. Inserts a `FormResponse` row.
2. Marks the FormInstance `Status='Submitted'`.
3. **Stamps the source PDF** with the filled values + signatures and writes to `FormFilledPdfs/{companyId}/{responseId}.pdf`.
4. **Emails the customer** the stamped PDF (if `sendToCustomerOnSubmit` was true).
5. Auto-acks the queue row.
6. Logs to `FormUsageLog` with Action=`Synced`.

### Request body

```json
{
  "companyId": "msProDemo1",
  "formInstanceId": 260,
  "queueId": 1,
  "templateId": 56,
  "appointmentId": "197",
  "customerId": "47",
  "deviceInfo": "iPhone 15 Pro / iOS 18.2 / TechApp 2.4.1",
  "responses": [
    {
      "fieldId": "pdf_1776367292253_hpb9ud",
      "label": "Customer Name",
      "type": "smartfield",
      "value": "John Smith",
      "position": { "page": 0, "xPct": 0.572, "yPct": 0.133, "wPct": 0.268, "hPct": 0.017 }
    },
    {
      "fieldId": "pdf_1776435526097_rjxkq4",
      "label": "Notes",
      "type": "textarea",
      "value": "Replaced filter, system running normally.",
      "position": { "page": 0, "xPct": 0.131, "yPct": 0.509, "wPct": 0.669, "hPct": 0.025 }
    },
    {
      "fieldId": "pdf_1777386410769_6pduup",
      "label": "Customer Signature",
      "type": "signature",
      "value": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
      "position": { "page": 0, "xPct": 0.676, "yPct": 0.916, "wPct": 0.264, "hPct": 0.053 }
    }
  ]
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `companyId` | string | yes | From poll. |
| `formInstanceId` | int | yes (>0) | From poll. |
| `queueId` | int | optional | From poll. If present, the queue row auto-acks. |
| `templateId` | int | yes (>0) | From poll. |
| `appointmentId` | string | yes (non-empty) | From poll. |
| `customerId` | string | recommended | From poll. Required if `sendToCustomerOnSubmit=true`, else email won't go out (no recipient). |
| `deviceInfo` | string | optional | Stored in `FormUsageLog.DeviceInfo`. |
| `responses` | array | yes | One entry per filled field. Empty array is allowed (will produce a stamped PDF with no overlays). |

### `responses[]` entry shape

| Field | Type | Notes |
|---|---|---|
| `fieldId` | string | The field's `id` from the template structure. **Required.** |
| `label` | string | Display name. Server doesn't depend on this for stamping (uses position from template). Recommended for audit/debugging. |
| `type` | string | One of: `text`, `textarea`, `number`, `date`, `dropdown`, `radio`, `checkbox`, `check`, `signature`, `smartfield`, `partstable`. **Must match template field type.** |
| `value` | string | Type-specific shape. **See [§8](#field-types--value-shape-reference).** Always serialize as a string, even for partstable JSON. |
| `position` | object | `{ page, xPct, yPct, wPct, hPct }`. Recommended (matches template); if you omit it, server falls back to template's stored position. |

### Example request

```bash
curl -X POST "https://testsite.myserviceforce.com/fsm/FaProSync.ashx?op=submit" \
  -H "X-Api-Key: fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5" \
  -H "Content-Type: application/json" \
  -d @submit-payload.json
```

### Example response (200 OK)

```json
{
  "success": true,
  "formResponseId": 50,
  "instancesUpdated": 1,
  "stampedPdfUrl": "/FormFilledPdfs/msProDemo1/50.pdf",
  "stampError": null,
  "emailStatus": "Email Sent Successfully",
  "emailError": null
}
```

| Field | Meaning |
|---|---|
| `formResponseId` | New FormResponse row ID. |
| `instancesUpdated` | Should be `1`. If `0`, the FormInstance lookup failed (likely a mismatched apptId/templateId/customerId). The response itself is still saved — just not linked. |
| `stampedPdfUrl` | App-relative URL to the stamped PDF. Prepend the base URL to display in-app. `null` if stamping failed (template wasn't a PDF, source PDF missing, etc.). |
| `stampError` | If non-null, the stamp pipeline hit an error. The form is still saved on the server — but no stamped PDF, no customer email. **Show a "form saved, PDF generation failed" message.** |
| `emailStatus` | Non-null if a customer email was attempted. Strings vary by mail provider — treat any value as "delivered to mail relay". |
| `emailError` | Non-null if email was attempted but failed. The form is still saved. |

### Edge cases

- **Template not found:** HTTP 404 `"Template {N} not found for company {X}"`. Don't retry — fix the templateId.
- **Stamp failure:** HTTP 200, `success: true`, but `stampError` populated and `stampedPdfUrl: null`. Surface the error to the tech but don't re-submit (data is saved, the form is "done").
- **Empty `responses[]`:** Allowed. PDF gets stamped with no overlays (just the source template).
- **Network timeout mid-submit:** **DON'T blindly retry.** See [§12 — retry rules](#retry--idempotency-rules).

---

## The form structure (template) explained

The `template.structure` field is a **JSON string** (not an object). Parse it once:

```javascript
const template = JSON.parse(item.template.structure);
```

The result has one of two shapes, distinguished by `mode`:

### `mode: "web"` — sectioned form

```json
{
  "version": "4.0",
  "mode": "web",
  "sections": [
    {
      "id": "section_xxx",
      "title": "Section 1",
      "rows": [
        {
          "id": "row_xxx",
          "fields": [
            { "id": "f1", "type": "text", "label": "Customer Name", "required": true },
            { "id": "f2", "type": "signature", "label": "Sign here" }
          ]
        }
      ]
    }
  ]
}
```

Render this with native form controls — no PDF involved. Iterate sections → rows → fields. Each row is a horizontal group; columns are determined by how the form-builder admin laid them out (typically 1, 2, or 3 fields per row).

### `mode: "pdf"` — PDF overlay form

```json
{
  "version": "4.0",
  "mode": "pdf",
  "pdfFile": {
    "path": "/FormTemplatePdfs/msProDemo1/56.pdf",
    "name": "Field_Service_Report.pdf",
    "pageCount": 2
  },
  "fields": [
    {
      "id": "pdf_1776367292253_hpb9ud",
      "header": "Customer Name",
      "type": "smartfield",
      "smartFieldSource": "customer.CustomerName",
      "required": false,
      "position": { "page": 0, "xPct": 0.572, "yPct": 0.133, "wPct": 0.268, "hPct": 0.017 }
    }
  ]
}
```

Render this by:
1. Downloading the PDF from `pdfFile.path` (see [§10](#downloading-the-source-pdf)).
2. Rendering each page (PDFKit on iOS, PdfRenderer on Android, or pdfjs cross-platform).
3. For each field, computing absolute position on the rendered page:
   ```
   inputX = pageWidth  * field.position.xPct
   inputY = pageHeight * field.position.yPct
   inputW = pageWidth  * field.position.wPct
   inputH = pageHeight * field.position.hPct
   ```
4. Overlaying a native input control of the right type at that position.

### ⚠️ Two critical quirks

1. **`header` vs `label`.** PDF-mode fields use `header`. Web-mode fields use `label`. When rendering or building responses, branch on it:
   ```javascript
   const displayName = field.header || field.label || 'Untitled';
   ```

2. **Coexisting empty arrays.** PDF-mode templates have `sections: []` (empty), and web-mode templates have `pdfFields` not present at all. Always check `mode` first; never iterate the wrong container.

---

## Field types — value shape reference

Every entry in `responses[]` has `type` + `value`. The `value` is **always a string**, but the string shape depends on `type`:

| Type | UI control | `value` shape | Example |
|---|---|---|---|
| `text` | Single-line text input | Plain string | `"John Smith"` |
| `textarea` | Multi-line text area | Plain string with `\n` for newlines | `"Line 1\nLine 2"` |
| `number` | Numeric input | Plain string of the number | `"42"` or `"3.14"` |
| `date` | Date picker | ISO date string `YYYY-MM-DD` | `"2026-04-28"` |
| `dropdown` | Single-select dropdown | The selected option's `value` (string) | `"Complete"` |
| `radio` | Radio group | The selected option's `value` (string) | `"Yes"` |
| `checkbox` | Multi-select checkbox group | **Comma-separated** list of selected values | `"Filter, Capacitor"` |
| `check` | Single yes/no checkbox | `"true"` or `"false"` (literal strings) | `"true"` |
| `signature` | Drawing pad | Full base64 data URL | `"data:image/png;base64,iVBORw0KGgo..."` |
| `smartfield` | Auto-filled text input | Plain string (the resolved value) | `"John Smith"` |
| `partstable` | Parts list builder | **JSON-stringified** object (see below) | `"{\"variant\":\"used\",\"rows\":[{...}]}"` |

### Special: `partstable` value shape

The `value` is a **JSON string** that, when parsed, has this shape:

```json
{
  "variant": "used",
  "rows": [
    { "itemId": "GUID-or-null", "name": "Air Filter", "description": "20x25x1 MERV 11", "qty": 2, "price": 12.50, "partNumber": "AF-2025M11" },
    { "itemId": null, "name": "Custom Part", "description": "Bracket — fabricated on-site", "qty": 1, "price": null, "partNumber": null }
  ]
}
```

- `variant` — `"used"` or `"toOrder"` (matches the template field's `variant`).
- `rows[]` — one entry per part. Drop fully-empty rows before sending.
  - `itemId` — pricebook GUID if the part came from the catalogue search, else `null` for free-form.
  - `qty` — number, `> 0` for non-empty rows.
  - `price` — number or `null`.
  - `partNumber` — string or `null`.

### Special: `signature` value shape

Must be a full base64 data URL with mime prefix:

```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
```

Recommended: PNG, white background, transparent or filled. Most signature pad libraries on iOS/Android can `toDataURL("image/png")` directly. Trim transparent margins so the PDF stamp looks tight.

### Special: `smartfield` and the `smartFieldData` from poll

If the field's `type` is `smartfield`, the **default value** comes from the `smartFieldData` map on the poll response:

```javascript
const smartFieldData = JSON.parse(item.smartFieldData);  // e.g. { "pdf_xxx": "John Smith", ... }
const prefillValue = smartFieldData[field.id] || "";
```

The tech can edit this — **submit whatever the input shows at submit time**, not what came from `smartFieldData`. Server uses the value you send, not the original.

If the smart field's source is unresolvable (e.g. `customer.JobTitle` and the customer has no JobTitle on file), the value will be empty string. Render an empty input.

---

## Smart fields — all sources

Smart fields are auto-filled by the server from existing FSM data. The mobile app gets the resolved values in `smartFieldData` on poll — no need to re-resolve on the device.

The `smartFieldSource` on each field is `"{entity}.{property}"`. Full reference:

### `customer.*` — pulled from the customer attached to the appointment

| Source | Returns |
|---|---|
| `customer.FirstName` | First name |
| `customer.LastName` | Last name |
| `customer.FullName` | "First Last" (concatenated, trimmed) |
| `customer.CustomerName` | Same as FullName |
| `customer.Email` | Email address |
| `customer.Phone` | Phone |
| `customer.Mobile` | Mobile |
| `customer.Address1` | Street address line 1 |
| `customer.Address2` | Street address line 2 |
| `customer.City` | City |
| `customer.State` | State / province |
| `customer.ZipCode` | Postal code |
| `customer.Country` | Country |
| `customer.CompanyName` | Customer's company (B2B) |
| `customer.BusinessName` | Business name (alternate) |
| `customer.JobTitle` | Job title |
| `customer.Title` | Mr/Mrs/etc |
| `customer.Notes` | Internal notes |

### `appointment.*` — pulled from the appointment

| Source | Returns |
|---|---|
| `appointment.ApptID` | Numeric appointment ID |
| `appointment.ServiceType` | Service-type ID (numeric string) |
| `appointment.RequestDate` | Requested date |
| `appointment.TimeSlot` | Time slot label |
| `appointment.ResourceName` | Assigned tech's name |
| `appointment.Status` | Current status |
| `appointment.Note` | Appointment-level note |
| `appointment.Duration` | Duration |
| `appointment.StartDateTime` | Scheduled start |
| `appointment.EndDateTime` | Scheduled end |

### `site.*` — pulled from the customer's site (location of the job)

| Source | Returns |
|---|---|
| `site.SiteName` | Site label |
| `site.Address` | Street address |
| `site.City` / `State` / `Zip` | Location parts |
| `site.Contact` | Contact name |
| `site.FirstName` / `LastName` | Contact name parts |
| `site.Email` | Contact email |
| `site.PhoneNumber` / `MobileNumber` | Contact phone |
| `site.Note` | Site-level note |

### `equipment.*` — pulled from installed equipment at the site

| Source | Returns |
|---|---|
| `equipment.EquipmentType` | Type label |
| `equipment.Make` | Manufacturer |
| `equipment.Model` | Model number |
| `equipment.SerialNumber` | Serial number |
| `equipment.Barcode` | Barcode |
| `equipment.InstallDate` | Install date |
| `equipment.WarrantyStart` | Warranty start |
| `equipment.WarrantyEnd` | Warranty end |
| `equipment.Notes` | Equipment notes |

### `resource.*` — pulled from the assigned tech

| Source | Returns |
|---|---|
| `resource.Name` | Tech's name |
| `resource.Email` | Tech's email |
| `resource.Mobile` | Tech's mobile |

### `system.*` — runtime values

| Source | Returns |
|---|---|
| `system.TodaysDate` | Today's date in `YYYY-MM-DD` |
| `system.CurrentTime` | Current time in `HH:mm` |
| `system.CurrentUser` | Logged-in user (server-side session — may be empty when called from mobile) |
| `system.CompanyName` | Company display name (server-side session — may be empty when called from mobile) |

> ⚠️ `system.CurrentUser` and `system.CompanyName` rely on the server's HTTP session, which the mobile API doesn't have. They'll come back as empty strings. If a template uses these and they matter to the mobile flow, raise it — we can patch the resolver to look them up by `companyId` directly.

> 🔤 Sources are case-insensitive on the server (`customer.firstname` and `customer.FirstName` both work).

---

## Downloading the source PDF

For PDF-mode templates, `pdfFile.path` is a **server-relative URL**. To get the actual PDF bytes:

```
fullUrl = baseUrlWithoutHandler + pdfFile.path
       = "https://testsite.myserviceforce.com/fsm/" + "/FormTemplatePdfs/msProDemo1/56.pdf"
       → strip the duplicate slash if needed
       = "https://testsite.myserviceforce.com/fsm/FormTemplatePdfs/msProDemo1/56.pdf"
```

Plain `GET`, returns `application/pdf`. **No auth header needed** — these PDFs are served from the static web root. (If you want them auth'd, that's a Phase 5 conversation — would need a new handler.)

### ⚠️ Path-prefix inconsistency

Some templates were saved with the `/fsm/` prefix already in the path, others without it:

| Template ID | Saved `pdfFile.path` |
|---|---|
| 56 | `/FormTemplatePdfs/msProDemo1/56.pdf` |
| 61 | `/fsm/FormTemplatePdfs/msProDemo1/61.pdf` |

Recommended client-side normalization:

```javascript
function buildPdfUrl(baseUrl, savedPath) {
  // baseUrl: "https://testsite.myserviceforce.com/fsm"  (no trailing slash)
  let p = savedPath;
  if (p.startsWith("/fsm/")) p = p.substring(4);   // strip leading /fsm
  if (!p.startsWith("/"))    p = "/" + p;
  return baseUrl + p;
}
// → "https://testsite.myserviceforce.com/fsm/FormTemplatePdfs/msProDemo1/56.pdf"
```

> 🔧 We can fix this server-side later — just flagging so you don't get caught.

### Caching

PDF templates are static — once downloaded for a (companyId, templateId), cache locally and reuse. Re-fetch only if a poll item references a new templateId you don't have, or if you want to handle templates being updated on the admin side (rare; if it matters, version the PDF by file size + last-modified header check).

---

## HTTP status codes & errors

Every error response is JSON: `{ "success": false, "error": "..." }`.

| Status | Meaning | Retry? |
|---|---|---|
| **200** | Success — but check `success:true` in the body. (Submit can be `success:true` with `stampError != null` — see [§6 edge cases](#edge-cases-2)) | n/a |
| **400** | Bad request shape — missing required fields, malformed JSON | No — fix the request |
| **401** | Bad/missing API key | No — fix the key |
| **404** | Template not found (submit only) | No — fix the templateId |
| **500** | Unhandled server crash | Yes, with exponential backoff |

---

## Retry & idempotency rules

Critical for offline-first behavior. Different ops have different retry semantics:

### `op=poll` — fully retry-safe

Pure read. Hammer it as much as you want.

### `op=ack` — fully retry-safe

The server's SP is idempotent. Calling ack on an already-Acked queueId returns 0 acked, no error. **Always retry on transient failures** (network drop, 500).

### `op=submit` — NOT blindly retry-safe

Each call inserts a new `FormResponse` row and stamps a new PDF. If submit succeeds but the response never reaches you (timeout / connection drop), retrying creates a duplicate.

**Recommended strategy:**

1. Submit times out → don't retry blindly.
2. Wait 30 seconds (server may still be processing).
3. Call `op=poll` for the same `(companyId, resourceId)`.
4. Look at the result:
   - **If `queueId` is no longer in the poll response** → submit landed. Don't retry. Mark as done locally.
   - **If `queueId` is still pending** → submit didn't land. Retry once.
5. After 3 failed retries → keep the form locally, surface "submit failed, will retry later" to the tech. Retry on next app foreground.

> 💡 **Future improvement (Phase 5):** Add an `idempotencyKey` field to the submit body so duplicate submits are detected server-side. Until then, use the poll-check strategy above.

---

## Polling cadence recommendation

| App state | Poll interval |
|---|---|
| **Foreground, online** | 30 seconds |
| **Background, online** | 5 minutes |
| **Just came back from offline** | Poll immediately |
| **Just opened the app** | Poll immediately |
| **Just acked some items** | Don't immediately re-poll for 30s — server already removed them |

If you implement **push notifications** later, you can poll less aggressively — just respond to the push by triggering a poll.

---

## Local development setup

If you want to test against a developer's machine running FSM (not prod):

1. Developer hits **F5** in Visual Studio. IIS Express boots on a random port — usually `localhost:62934`.
2. Developer tells you the port + the API key from `Web.config`.
3. Point the mobile app's base URL at `http://localhost:62934/`.
4. Developer triggers a Phase 2 status change (e.g. drag an appointment to "Arrived" in the FSM web UI) → that creates a row in `FaProSyncQueue`.
5. Mobile app polls and sees it.

For a no-mobile-app test: any of the curl examples in this doc work as-is.

---

## Known issues & roadmap

| Status | Item |
|---|---|
| ✅ Working | Poll, ack, submit, smart-field server-side resolution, PDF stamping, customer email |
| ⚠️ Pre-existing bug | `PdfStampProcessor` rejects PDF templates whose saved path includes `/fsm/` when running on a server without that virtual dir prefix. Surfaces as `stampError: "Source PDF not found on server: "`. Fix tracked separately. |
| 🟡 MVP shortcut | Single global API key for all companies. Per-company keys deferred to Phase 5. Contract for the mobile dev won't change. |
| 🟡 MVP shortcut | `op=submit` not idempotent at server. Use poll-check retry strategy (see [§12](#retry--idempotency-rules)). Server-side idempotency keys are Phase 5. |
| 🟡 Phase 4 (server-side, no mobile change) | Per-template "email customer on completion" toggle. When this ships, `sendToCustomerOnSubmit` may be true even if the trigger didn't set it (template-level default). No mobile-side change required. |
| 🔵 Phase 5 backlog | Push notifications, per-device tokens, webhooks, Cancel action, idempotency keys, `system.CurrentUser`/`CompanyName` resolution for mobile context |

---

## Appendix A — full real example (PDF template with smart fields)

This is template `Id=56` ("Field Service Report") on company `msProDemo1`. **Real production data.**

### Poll response — single item

```json
{
  "success": true,
  "count": 1,
  "items": [
    {
      "queueId": 1,
      "formInstanceId": 260,
      "appointmentId": "197",
      "templateId": 56,
      "resourceId": 2444,
      "action": "Push",
      "triggerId": 3,
      "createdDateTime": "2026-04-27T15:39:45",
      "customerId": "47",
      "instanceStatus": "Pending",
      "sendToCustomerOnSubmit": false,
      "template": {
        "id": 56,
        "name": "Field Service Report",
        "description": "",
        "structure": "{...see below...}",
        "requireSignature": false,
        "requireTip": false
      },
      "smartFieldData": "{\"pdf_1776367292253_hpb9ud\":\"John Smith\",\"pdf_1776367962325_m4i3fa\":\"Acme HVAC Demo\",\"pdf_1776368042085_sbl3iz\":\"Tech Tahmid\",\"pdf_1776434855810_mj19bh\":\"123 Main St\",\"pdf_1776434919656_bf6sft\":\"555-0100\",\"pdf_1776434968075_0uyjp4\":\"john@example.com\",\"pdf_1776435044204_xm4btd\":\"555-0200\",\"pdf_1776435246938_6sv7bu\":\"2026-04-28\",\"pdf_1776436636447_8qlrs8\":\"197\"}"
    }
  ]
}
```

### Parsed `template.structure`

```json
{
  "version": "4.0",
  "mode": "pdf",
  "pdfFile": {
    "path": "/FormTemplatePdfs/msProDemo1/56.pdf",
    "name": "Field_Service_Report_General.pdf",
    "pageCount": 2
  },
  "fields": [
    { "id": "pdf_1776367292253_hpb9ud", "header": "Customer Name", "type": "smartfield",
      "smartFieldSource": "customer.CustomerName",
      "position": { "page": 0, "xPct": 0.572, "yPct": 0.133, "wPct": 0.268, "hPct": 0.017 } },

    { "id": "pdf_1776367962325_m4i3fa", "header": "Company Name", "type": "smartfield",
      "smartFieldSource": "system.CompanyName",
      "position": { "page": 0, "xPct": 0.206, "yPct": 0.130, "wPct": 0.222, "hPct": 0.019 } },

    { "id": "pdf_1776368042085_sbl3iz", "header": "Technician Name", "type": "smartfield",
      "smartFieldSource": "resource.Name",
      "position": { "page": 0, "xPct": 0.212, "yPct": 0.153, "wPct": 0.215, "hPct": 0.019 } },

    { "id": "pdf_1776434855810_mj19bh", "header": "Customer Address", "type": "smartfield",
      "smartFieldSource": "customer.Address1",
      "position": { "page": 0, "xPct": 0.575, "yPct": 0.152, "wPct": 0.269, "hPct": 0.021 } },

    { "id": "pdf_1776435526097_rjxkq4", "header": "Text Area", "type": "textarea",
      "position": { "page": 0, "xPct": 0.131, "yPct": 0.509, "wPct": 0.669, "hPct": 0.025 } }

    /* ...more fields (signatures, dates, etc.) — same structure */
  ],
  "sections": [],
  "lastModified": "2026-04-17T18:02:01.549Z"
}
```

### Submit body

```json
{
  "companyId": "msProDemo1",
  "formInstanceId": 260,
  "queueId": 1,
  "templateId": 56,
  "appointmentId": "197",
  "customerId": "47",
  "deviceInfo": "iPhone 15 Pro / iOS 18.2 / TechApp 2.4.1",
  "responses": [
    { "fieldId": "pdf_1776367292253_hpb9ud", "label": "Customer Name",  "type": "smartfield", "value": "John Smith" },
    { "fieldId": "pdf_1776367962325_m4i3fa", "label": "Company Name",   "type": "smartfield", "value": "Acme HVAC Demo" },
    { "fieldId": "pdf_1776368042085_sbl3iz", "label": "Technician Name","type": "smartfield", "value": "Tech Tahmid" },
    { "fieldId": "pdf_1776434855810_mj19bh", "label": "Customer Address","type": "smartfield","value": "123 Main St, Springfield" },
    { "fieldId": "pdf_1776435526097_rjxkq4", "label": "Text Area",      "type": "textarea",   "value": "Replaced filter, system running normally.\nNo further action needed." }
  ]
}
```

### Submit response

```json
{
  "success": true,
  "formResponseId": 50,
  "instancesUpdated": 1,
  "stampedPdfUrl": "/FormFilledPdfs/msProDemo1/50.pdf",
  "stampError": null,
  "emailStatus": null,
  "emailError": null
}
```

To view the stamped PDF: `https://testsite.myserviceforce.com/fsm/FormFilledPdfs/msProDemo1/50.pdf`

---

## Appendix B — full real example (PDF template with parts table)

Template `Id=61` ("Service Report 001 PDF Test"). Demonstrates `partstable`, `signature`, `dropdown`, `check`, and mixed smart/non-smart fields.

### Parsed `template.structure`

```json
{
  "version": "4.0",
  "mode": "pdf",
  "pdfFile": {
    "path": "/fsm/FormTemplatePdfs/msProDemo1/61.pdf",
    "name": "service_report.pdf",
    "pageCount": 1
  },
  "fields": [
    { "id": "pdf_1777386351139_kfgiue", "type": "partstable", "header": "Parts Used",
      "variant": "used", "maxRows": 4,
      "columns": { "qty": true, "description": true, "partNumber": false, "price": false },
      "position": { "page": 0, "xPct": 0.042, "yPct": 0.676, "wPct": 0.458, "hPct": 0.142 } },

    { "id": "pdf_1777386365481_zl7ny9", "type": "partstable", "header": "Parts to order",
      "variant": "toOrder", "maxRows": 4,
      "columns": { "qty": true, "description": true, "partNumber": false, "price": false },
      "position": { "page": 0, "xPct": 0.502, "yPct": 0.678, "wPct": 0.451, "hPct": 0.139 } },

    { "id": "pdf_1777386410769_6pduup", "type": "signature", "header": "Customer Signature",
      "position": { "page": 0, "xPct": 0.676, "yPct": 0.916, "wPct": 0.264, "hPct": 0.053 } },

    { "id": "pdf_1777386576426_6hijdz", "type": "smartfield", "header": "Smart Field",
      "smartFieldSource": "",
      "position": { "page": 0, "xPct": 0.183, "yPct": 0.198, "wPct": 0.220, "hPct": 0.016 } },

    { "id": "pdf_1777386597093_su6ezo", "type": "smartfield", "header": "post code",
      "smartFieldSource": "customer.ZipCode",
      "position": { "page": 0, "xPct": 0.180, "yPct": 0.280, "wPct": 0.187, "hPct": 0.017 } },

    { "id": "pdf_1777386655934_9ohqqz", "type": "smartfield", "header": "Service Type",
      "smartFieldSource": "appointment.ServiceType",
      "position": { "page": 0, "xPct": 0.632, "yPct": 0.224, "wPct": 0.205, "hPct": 0.019 } },

    { "id": "pdf_1777386726766_yuhsqu", "type": "dropdown", "header": "Job Status",
      "options": ["Complete", "InComplete"],
      "position": { "page": 0, "xPct": 0.637, "yPct": 0.280, "wPct": 0.209, "hPct": 0.020 } },

    { "id": "pdf_1777386796329_svs9x7", "type": "check", "header": "Balance Room",
      "position": { "page": 0, "xPct": 0.250, "yPct": 0.332, "wPct": 0.027, "hPct": 0.015 } },

    { "id": "pdf_1777386821007_zx8m3b", "type": "textarea", "header": "General Remarks",
      "position": { "page": 0, "xPct": 0.044, "yPct": 0.421, "wPct": 0.922, "hPct": 0.213 } }
  ],
  "sections": [],
  "lastModified": "2026-04-28T14:34:01.613Z"
}
```

### Submit body (typical filled form)

```json
{
  "companyId": "msProDemo1",
  "formInstanceId": 261,
  "queueId": 2,
  "templateId": 61,
  "appointmentId": "197",
  "customerId": "47",
  "deviceInfo": "iPhone 15 Pro / iOS 18.2 / TechApp 2.4.1",
  "responses": [
    {
      "fieldId": "pdf_1777386351139_kfgiue",
      "label": "Parts Used",
      "type": "partstable",
      "value": "{\"variant\":\"used\",\"rows\":[{\"itemId\":null,\"name\":\"Air Filter\",\"description\":\"20x25x1 MERV 11\",\"qty\":2,\"price\":12.50,\"partNumber\":\"AF-2025M11\"},{\"itemId\":null,\"name\":\"Capacitor\",\"description\":\"45/5 µF dual run\",\"qty\":1,\"price\":18.00,\"partNumber\":\"CAP-455\"}]}"
    },
    {
      "fieldId": "pdf_1777386365481_zl7ny9",
      "label": "Parts to order",
      "type": "partstable",
      "value": "{\"variant\":\"toOrder\",\"rows\":[]}"
    },
    {
      "fieldId": "pdf_1777386410769_6pduup",
      "label": "Customer Signature",
      "type": "signature",
      "value": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
    },
    { "fieldId": "pdf_1777386597093_su6ezo", "label": "post code",     "type": "smartfield", "value": "62701" },
    { "fieldId": "pdf_1777386655934_9ohqqz", "label": "Service Type",  "type": "smartfield", "value": "HVAC" },
    { "fieldId": "pdf_1777386726766_yuhsqu", "label": "Job Status",    "type": "dropdown",   "value": "Complete" },
    { "fieldId": "pdf_1777386796329_svs9x7", "label": "Balance Room",  "type": "check",      "value": "true" },
    { "fieldId": "pdf_1777386821007_zx8m3b", "label": "General Remarks","type": "textarea",  "value": "Initial inspection complete.\nAll readings within spec." }
  ]
}
```

---

## Questions? Issues?

- **Server-side bug or unclear behavior:** Ping Tahmid (FSM dev).
- **Field type or smart-field source not in the table:** Probably a new admin-side feature — check with Tahmid before assuming it's safe to send.
- **Want a dry-run / sandbox queue with no real customers:** Tahmid can seed a synthetic appointment + trigger combo on the demo company.

---

# Recent changes (additive — older ops still work as documented above)

Each entry is dated. Read top-down to follow the API's evolution since the last hand-off.

## 2026-05-28 — `op=submit` response: new fields for CSL Files

When a form is submitted via `op=submit`, the stamped PDF is **now also saved into the Customer Service Location's Files tab** (`msSchedulerV3.tbl_Files`). Field techs see the just-submitted PDF on the customer/site Files list immediately, mirroring the web-submit path.

**Existing response shape — unchanged keys, two new ones:**

```json
{
  "success":          true,
  "formResponseId":   12345,
  "instancesUpdated": 1,
  "stampedPdfUrl":    "/fsm/FormFilledPdfs/msProDemo1/12345.pdf",
  "stampError":       null,
  "emailStatus":      "Sent",
  "emailError":       null,

  // ↓↓ NEW fields ↓↓
  "cslFileStatus":    "saved",      // "saved" | "no-row-inserted" | null
  "cslFileError":     null          // exception message if the CSL-Files write failed
}
```

- **You don't need to do anything new** — the CSL write is fire-and-forget, server-side. Existing client code that reads `success` / `stampedPdfUrl` still works.
- Failures here **never block** the response submit — `cslFileError` is informational only.
- The same auto-save runs on the web submit path (`Forms.aspx/SaveFormResponse`) so the Files tab is consistent across surfaces.

## 2026-05-28 — `FilledBy` now populated on submit

The `FormInstances.FilledBy` column (visible on CustomerDetails → Forms tab "User ID" column) is now updated on submit. Mobile submissions write `"Fa Pro Mobile"` (or `"Fa Pro Mobile: <deviceInfo>"` when the request supplied `deviceInfo`). Web submissions write the logged-in user's email, or `"Customer"` for public form-fill links.

**Existing behaviour that also changed (heads-up):** Re-submitting a previously `Cancelled` form instance now flips it back to `Submitted` (the response is preserved). Before this change, the row stayed `Cancelled` even after a fresh response was saved — confusing on the Forms tab.

No client-side change required.

## 2026-05-28 — NEW field type: `image` (in FormStructure templates)

Templates returned by `op=poll` can now contain fields of `type: "image"`. The desktop builder lets admins drop these onto a PDF with an optional pre-uploaded default image (logo, header, stamp, etc.) and an `allowEdit` flag controlling whether the user can replace it.

**Field JSON shape:**

```json
{
  "id": "field_abc123",
  "type": "image",
  "header": "Company Logo",
  "required": false,
  "defaultValue": "data:image/png;base64,iVBOR...",  // optional; designer-set pre-fill
  "allowEdit": true,                                  // false = locked, user cannot replace
  "position": { "page": 0, "xPct": 0.1, "yPct": 0.1, "wPct": 0.16, "hPct": 0.12 }
}
```

**Mobile rendering (PDF mode):**

| Situation | What to render |
|---|---|
| `defaultValue` set, `allowEdit: true` (or omitted) | Show the image, plus an "Upload / Replace" button |
| `defaultValue` set, `allowEdit: false` | Show the image only — locked, no upload UI |
| `defaultValue` empty, `allowEdit: true` | Show an "Upload" button / drop zone |
| `defaultValue` empty, `allowEdit: false` | Edge case — render empty placeholder; admin probably forgot to pre-fill |

When the user picks an image from camera / library, send it back as a `data:image/<type>;base64,…` URL in the response array — same shape as a signature value.

**Submit payload example:**

```json
{
  "fieldId": "field_abc123",
  "label": "Company Logo",
  "type": "image",
  "value": "data:image/jpeg;base64,/9j/4AAQSkZJRgABA..."
}
```

If the user didn't change a locked default, you can send `value: ""` or omit it entirely — the server falls back to the template's `defaultValue` when stamping the PDF, so locked logos always appear on the stamped output.

**Backward compatibility:** if your renderer doesn't handle `image` type yet, **add a guard so it doesn't crash on `field.type === "image"`** — render an empty box or skip it. The PDF will still stamp the default image server-side regardless.

**Size cap:** the desktop builder enforces 5 MB per image. Same recommended cap on mobile uploads. The poll response carrying a 5 MB default base64-encodes to ~6.5 MB — confirm your HTTP client handles that.

## 2026-05-28 — NEW op: `emailPdf` (on-demand resend of stamped PDF to customer)

**Use case:** the tech finishes a job, reviews the submitted PDF on their phone, and wants to push a "Send to customer" button to email the stamped PDF. This op is the trigger — no `SendToCustomerOnSubmit` gate, no DB flag dependency.

```
POST /fsm/FaProSync.ashx?op=emailPdf
X-Api-Key: <FaProApiKey>
Content-Type: application/json; charset=utf-8
```

**Body — supply ONE of these two identifier shapes:**

```jsonc
// Shape A — preferred when you have the formResponseId from op=submit
{
  "companyId":      "msProDemo1",
  "formResponseId": 57
}

// Shape B — natural key; resolves the latest matching FormResponse (Id DESC)
{
  "companyId":     "msProDemo1",
  "templateId":    3,
  "appointmentId": "10248",
  "customerId":    47
}
```

**Optional override (either shape):**

```jsonc
"to": "override@example.com"   // bypasses customer-email lookup — useful for QA / dry-runs
```

**Success response (HTTP 200):**

```json
{
  "success":        true,
  "formResponseId": 57,
  "templateId":     60,
  "appointmentId":  "197",
  "customerId":     47,
  "toEmail":        "customer@example.com",
  "templateName":   "SERVICE REPORT 001 PDF",
  "emailStatus":    "Sent",
  "emailError":     null
}
```

`success: true` with a non-null `emailError` is possible if the SMTP send raised but the lookup + file location succeeded — treat as soft failure and surface to the tech for retry.

**Error responses (status code + JSON `{success:false, error:"..."}`):**

| Status | Cause |
|---|---|
| 400 | Missing `companyId` |
| 400 | Neither `formResponseId` nor the full natural-key trio supplied |
| 400 | Customer has no email on file **and** no `to` override provided |
| 401 | Missing / invalid `X-Api-Key` |
| 404 | No `FormResponse` row matches the identifiers |
| 404 | Stamped PDF not found on disk (web-mode submission, or stamping failed at submit time) |
| 500 | Uncaught exception (`error` carries the message) |

**Behaviour details:**

- The endpoint is **retry-safe** — calling it twice sends two copies. Up to the mobile UI to disable the button after a success.
- Calling this **after** an `op=submit` that already returned `emailStatus: "Sent"` will send the email a second time. Either skip the call when the auto-email already fired, or expose both buttons and let the tech decide.
- Email subject + body are identical to the auto-email branch: `"Your form submission: <template name>"` with a short HTML greeting and the stamped PDF attached as `<sanitised-template-name>.pdf`.
- Lookups use `ORDER BY Id DESC`, so for repeatedly-submitted forms (same template + appointment + customer) the **most recent** submission is the one emailed. If you need a specific older one, pass its `formResponseId` explicitly.

**curl smoke-test:**

```bash
curl -X POST "https://YOUR_HOST/fsm/FaProSync.ashx?op=emailPdf" \
  -H "X-Api-Key: <FaProApiKey>" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"companyId":"msProDemo1","formResponseId":57}'
```

# FaProMobile API

Mobile API for the FSM Customer Service Location resources — Notes, Pictures, Files, Equipment. Single handler, dispatched via query params.

---

## 1. Base URL

| Environment | Base URL                                                   |
| ----------- | ---------------------------------------------------------- |
| Live (mxp)  | `https://mxp.myserviceforce.com/fsm/FaProMobile.ashx`      |
| Testsite    | `https://testsite.myserviceforce.com/fsm/FaProMobile.ashx` |
| Local dev   | `http://localhost:62934/FaProMobile.ashx`                  |

Every request goes to the SAME path. Routing happens via two required query params:

```
{baseUrl}?resource={resource}&op={op}&companyId={companyId}&...other-params
```

`resource` is one of: `notes`, `pictures`, `files`, `equipment`.
`op` is one of: `list`, `create`, `createBatch`, `update`, `delete` (plus `equipmentTypes` under `resource=equipment`). `createBatch` is supported for `notes`, `pictures`, and `files` — see §5.1/§5.2/§5.3.

---

## 2. Authentication

A single shared API key, sent on every request. Two equivalent ways to send it:

**Recommended — HTTP header:**

```
X-Api-Key: fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5
```

**Alternative — query string** (if header isn't convenient for the framework):

```
?apiKey=fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5
```

If both header and query param are present, header wins.
Missing/wrong key → HTTP **401** with JSON envelope (see §4).

> **MVP note.** A single global key is shared by all companies in this phase. Future Phase 5 will move to per-device tokens. The key value above is the current one in `Web.config:FaProApiKey`; rotate via deployment, no app change needed.

---

## 3. Required parameters on every request

| Param       | Location     | Notes                                                                                                                                                                                                                                         |
| ----------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `resource`  | query string | `notes` \| `pictures` \| `files` \| `equipment`                                                                                                                                                                                               |
| `op`        | query string | `list` \| `create` \| `update` \| `delete` (or `equipmentTypes` for the equipment catalog)                                                                                                                                                    |
| `companyId` | query string | The FSM CompanyID the caller is acting as. **Always required**, even for the global `equipmentTypes` op. Server enforces this in every WHERE clause — supplying the wrong `companyId` will return 404 on any write op (cross-tenant scoping). |

API key must always be present. All other params are per-op (see §5).

---

## 4. JSON shapes

### Success envelope — read (list)

```json
{
  "success": true,
  "count": 3,
  "items": [
    /* objects */
  ]
}
```

### Success envelope — write (create / update / delete)

```json
{ "success": true, "id": 123 }      // create returns the new id
{ "success": true }                  // update / delete
```

For picture create, the response also includes the absolute `fileUrl` so mobile can render it immediately:

```json
{
  "success": true,
  "id": 167,
  "fileUrl": "https://mxp.myserviceforce.com/fsm/FSMPictures/14590/242384/photo.jpg"
}
```

### Error envelope

```json
{ "success": false, "error": "Human-readable message" }
```

### HTTP status codes

| Code | Meaning                                                                   |
| ---- | ------------------------------------------------------------------------- |
| 200  | Success                                                                   |
| 400  | Bad request (missing required field, unparseable id, unknown resource/op) |
| 401  | Auth failure — bad/missing API key                                        |
| 404  | Row not found OR not owned by the supplied `companyId` (write ops)        |
| 405  | Wrong HTTP method (e.g., `GET` on a `create` op)                          |
| 500  | Server error — message in `error`                                         |

**IIS custom errors are bypassed.** Even on 4xx/5xx, the body is always JSON in the shapes above — never an IIS HTML page.

### Other conventions

- Keys are **camelCase**.
- Dates are **ISO 8601** without timezone: `yyyy-MM-ddTHH:mm:ss` (e.g. `2026-05-19T14:13:50`). Mobile should parse these as local server time.
- Missing optional values are returned as `null` (or omitted strings as `""`).
- All numeric ids are JSON integers.

---

## 5. Endpoints

All 17 endpoints below assume the API key + `companyId` from §3 are also present. Examples use `curl.exe` — works on Windows PowerShell and from Bash.

### 5.1 Notes

DB-backed by `tbl_Note` with `TaggedFrom='FSM'`. Notes are customer-level and scoped to a site.

#### `GET ?resource=notes&op=list`

Query string: `customerId`, `siteId`.

```bash
curl -H "X-Api-Key: $KEY" \
  "$BASE?resource=notes&op=list&companyId=14590&customerId=242384&siteId=1452"
```

Response items:

```json
{
  "id": 6163,
  "description": "Replace filter on next visit",
  "reference": "tech-followup",
  "createdAt": "2026-05-19T14:13:50",
  "userId": "tech.smith@myserviceforce.com",
  "taggedTo": "",
  "taggedFrom": "FSM",
  "appointmentId": "197",
  "customerId": "242384",
  "siteId": 1452
}
```

#### `POST ?resource=notes&op=create`

JSON body:

| Field           | Type   | Required | Notes                                                                                                                       |
| --------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| `customerId`    | string | yes      |                                                                                                                             |
| `siteId`        | int    | yes      | `0` allowed (= default site)                                                                                                |
| `description`   | string | yes      |                                                                                                                             |
| `reference`     | string | no       |                                                                                                                             |
| `appointmentId` | int    | no       | Pass the current appointment id so the note is tagged. If omitted/empty → `NULL`. Non-positive or unparseable values → 400. |
| `taggedTo`      | string | no       |                                                                                                                             |
| `taggedFrom`    | string | no       | Defaults to `"FSM"`                                                                                                         |
| `userId`        | string | no       | Defaults to `"FaProMobile"`                                                                                                 |

```bash
curl -X POST -H "X-Api-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"customerId":"242384","siteId":1452,"appointmentId":197,"description":"Replace filter on next visit","reference":"tech-followup"}' \
  "$BASE?resource=notes&op=create&companyId=14590"
```

Returns `{"success":true,"id":6163}`.

#### `POST ?resource=notes&op=createBatch`

JSON body: `{ "items": [ { ...same shape as notes/create body... }, ... ] }`. Max 100 items per batch.

Each item is validated independently — one bad item does NOT roll back the others. The top-level `success: true` only means the batch endpoint ran; check each `items[i].success` for per-row outcome. Items that fail validation are simply not inserted (no row created); the surrounding successful items are persisted.

```bash
curl -X POST -H "X-Api-Key: $KEY" -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"customerId":"242384","siteId":1452,"appointmentId":197,"description":"Filter replaced"},
      {"customerId":"242384","siteId":1452,"appointmentId":201,"description":"Compressor ok","reference":"qa-pass"}
    ]
  }' \
  "$BASE?resource=notes&op=createBatch&companyId=14590"
```

Response:

```json
{
  "success": true,
  "count": 2,
  "items": [
    { "index": 0, "success": true, "id": 6164 },
    { "index": 1, "success": true, "id": 6165 }
  ]
}
```

On per-item failure the entry looks like `{"index": N, "success": false, "error": "Invalid appointmentId"}`.

#### `POST ?resource=notes&op=update`

JSON body: `{ noteId (int, required), description (string, required), taggedTo?, taggedFrom? }`.
Returns `{"success":true}` on success, `404` if the note doesn't exist or isn't owned by this `companyId`.

#### `POST ?resource=notes&op=delete`

JSON body: `{ noteId }`. Returns `{"success":true}` / 404.

---

### 5.2 Pictures

DB-backed by `tbl_Pictures`. Images are saved to disk at `~/FSMPictures/{companyId}/{customerId}/{filename}` on the server, and the absolute URL is stored in the `PictureURL` column.

#### `GET ?resource=pictures&op=list`

Query string: `customerId`, `siteId`.

Response items:

```json
{
  "id": 167,
  "fileName": "WhatsApp Image 2026-05-16.jpeg",
  "fileUrl": "https://mxp.myserviceforce.com/fsm/FSMPictures/14590/242384/WhatsApp Image 2026-05-16.jpeg",
  "uploadDate": "2026-05-19T14:12:00",
  "uploadedBy": "admin@myserviceforce.com",
  "appointmentId": 197,
  "reference": "before-photo",
  "taggedFrom": "FSM",
  "taggedTo": null,
  "siteId": 1452
}
```

`fileUrl` is always an absolute URL. Mobile can `GET` it directly (no API key needed for the file itself — it's served as a static asset by IIS).

#### `POST ?resource=pictures&op=create` (multipart/form-data)

**Content-Type:** `multipart/form-data`. NOT JSON.

| Form field      | Type       | Required | Notes                                                                      |
| --------------- | ---------- | -------- | -------------------------------------------------------------------------- |
| `file`          | file part  | yes      | Send as a real multipart file part. Max 25 MB.                             |
| `customerId`    | text       | yes      |                                                                            |
| `siteId`        | text (int) | yes      | `0` allowed                                                                |
| `appointmentId` | text (int) | no       | Pass the current appointment id so the row is tagged. If omitted → `NULL`. |
| `reference`     | text       | no       |                                                                            |
| `uploadedBy`    | text       | no       | Defaults to `"FaProMobile"`                                                |

```bash
curl -X POST -H "X-Api-Key: $KEY" \
  -F "customerId=242384" -F "siteId=1452" -F "appointmentId=197" \
  -F "reference=before-photo" \
  -F "file=@/path/to/photo.jpg;type=image/jpeg" \
  "$BASE?resource=pictures&op=create&companyId=14590"
```

Returns `{"success":true,"id":167,"fileUrl":"https://…/photo.jpg"}`.

Filename behavior: server sanitizes the filename (alphanumeric / `-` / `_` / `.` only). If a file with the same name already exists in the target folder, an 8-char GUID prefix is added (e.g. `5128d17f_photo.jpg`).

#### `POST ?resource=pictures&op=createBatch` (multipart/form-data)

Bulk upload of multiple images in a single request. Shared metadata — one `customerId`, `siteId`, `appointmentId?`, `reference?`, `uploadedBy?` applies to every file part. Send multiple `file` parts (repeat the field name).

| Form field      | Type                 | Required | Notes                                                                                                |
| --------------- | -------------------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `file`          | file part (repeated) | yes      | One or more multipart file parts. Same name `file` for each. Max 50 files per batch; each max 25 MB. |
| `customerId`    | text                 | yes      |                                                                                                      |
| `siteId`        | text (int)           | yes      | `0` allowed                                                                                          |
| `appointmentId` | text (int)           | no       | Applied to every row in the batch                                                                    |
| `reference`     | text                 | no       | Applied to every row in the batch                                                                    |
| `uploadedBy`    | text                 | no       | Defaults to `"FaProMobile"`                                                                          |

```bash
curl -X POST -H "X-Api-Key: $KEY" \
  -F "file=@/path/before-1.jpg;type=image/jpeg" \
  -F "file=@/path/before-2.jpg;type=image/jpeg" \
  -F "file=@/path/before-3.jpg;type=image/jpeg" \
  -F "customerId=242384" -F "siteId=1452" -F "appointmentId=197" \
  -F "reference=before" \
  "$BASE?resource=pictures&op=createBatch&companyId=14590"
```

Response (per-file partial success):

```json
{
  "success": true,
  "count": 3,
  "items": [
    {
      "index": 0,
      "success": true,
      "id": 168,
      "fileName": "before-1.jpg",
      "fileUrl": "https://…/before-1.jpg"
    },
    {
      "index": 1,
      "success": false,
      "fileName": "before-2.jpg",
      "error": "File exceeds 25 MB limit"
    },
    {
      "index": 2,
      "success": true,
      "id": 169,
      "fileName": "before-3.jpg",
      "fileUrl": "https://…/before-3.jpg"
    }
  ]
}
```

A failed file leaves no DB row and no on-disk artifact; successful siblings stay saved.

#### `POST ?resource=pictures&op=update` (metadata only — no file replacement)

JSON body: `{ pictureId, reference }`. Replaces only the `Reference` column. To replace the image content, call `delete` + `create`.

#### `POST ?resource=pictures&op=delete`

JSON body: `{ pictureId }`. Deletes both the DB row AND the file on disk (best-effort — handles both absolute and legacy relative `PictureURL` values).

---

### 5.3 Files

DB-backed by `tbl_Files`. Unlike pictures, file bytes are stored as `varbinary(max)` inside the database; there is no on-disk file. Downloads stream from the DB.

#### `GET ?resource=files&op=list`

Same params as pictures (`customerId`, `siteId`).

Response items:

```json
{
  "id": 43,
  "fileName": "GPI-Client Worksheet.pdf",
  "fileType": "application/pdf",
  "fileSize": 1132590,
  "fileUrl": "https://mxp.myserviceforce.com/fsm/CustomerDetails.aspx?type=file&id=43",
  "uploadDate": "2026-05-19T14:13:07",
  "uploadedBy": "admin@myserviceforce.com",
  "appointmentId": 197,
  "reference": "spec-sheet",
  "taggedFrom": "FSM",
  "taggedTo": null,
  "siteId": 1452
}
```

> **Limitation:** `fileUrl` currently points at a session-authenticated page (`CustomerDetails.aspx?type=file&id=N`). Hitting it without a logged-in browser session won't return the file bytes. A sessionless `files&op=download` endpoint is planned as a follow-up. Until then, mobile should display metadata only and trigger the download through the user's authenticated browser if needed.

#### `POST ?resource=files&op=create` (multipart/form-data)

Same form fields as pictures (`file`, `customerId`, `siteId`, `appointmentId?`, `reference?`, `uploadedBy?`). Max 50 MB.

`FileType` is read from the multipart `Content-Type` of the file part (defaults to `application/octet-stream`). `FileSize` is computed by the server.

```bash
curl -X POST -H "X-Api-Key: $KEY" \
  -F "customerId=242384" -F "siteId=1452" -F "appointmentId=197" \
  -F "file=@/path/to/spec.pdf;type=application/pdf" \
  "$BASE?resource=files&op=create&companyId=14590"
```

Returns `{"success":true,"id":47}`.

#### `POST ?resource=files&op=createBatch` (multipart/form-data)

Same shape as `pictures/createBatch` — shared metadata, repeated `file` parts. Max **20 files** per batch (lower than pictures because file bytes are stored in the DB and can be up to 50 MB each).

| Form field      | Type                 | Required | Notes                             |
| --------------- | -------------------- | -------- | --------------------------------- |
| `file`          | file part (repeated) | yes      | Max 20 per batch; each max 50 MB. |
| `customerId`    | text                 | yes      |                                   |
| `siteId`        | text (int)           | yes      | `0` allowed                       |
| `appointmentId` | text (int)           | no       | Applied to every row              |
| `reference`     | text                 | no       | Applied to every row              |
| `uploadedBy`    | text                 | no       | Defaults to `"FaProMobile"`       |

```bash
curl -X POST -H "X-Api-Key: $KEY" \
  -F "file=@/path/report-a.pdf;type=application/pdf" \
  -F "file=@/path/report-b.pdf;type=application/pdf" \
  -F "customerId=242384" -F "siteId=1452" -F "appointmentId=197" \
  -F "reference=service-reports" \
  "$BASE?resource=files&op=createBatch&companyId=14590"
```

Response:

```json
{
  "success": true,
  "count": 2,
  "items": [
    { "index": 0, "success": true, "id": 50, "fileName": "report-a.pdf" },
    { "index": 1, "success": true, "id": 51, "fileName": "report-b.pdf" }
  ]
}
```

#### `POST ?resource=files&op=update`

JSON body: `{ fileId, fileName?, reference? }` — at least one of `fileName`/`reference` is required. Cannot replace the file bytes; for that, `delete` + `create`.

#### `POST ?resource=files&op=delete`

JSON body: `{ fileId }`.

---

### 5.4 Equipment

DB-backed by `tbl_Equipment`. Each row belongs to a customer (via `CustomerGuid`) and a site.

#### `GET ?resource=equipment&op=list`

Query string: `customerGuid`, `siteId`. (Note: this resource uses `customerGuid`, not `customerId`, because that's the FK on `tbl_Equipment`.)

```bash
curl -H "X-Api-Key: $KEY" \
  "$BASE?resource=equipment&op=list&companyId=14590&customerGuid=93C735B4-0DF3-4968-83D8-D833E629A79E&siteId=1452"
```

Response items:

```json
{
  "id": 571,
  "siteId": 1452,
  "customerGuid": "93C735B4-0DF3-4968-83D8-D833E629A79E",
  "customerId": "242384",
  "customerName": "Imtiaz Farhina",
  "make": "Trane",
  "model": "XR17",
  "notes": "Replaced compressor 2024",
  "barcode": "BC-2525",
  "serialNumber": "SN-1245",
  "equipmentTypeId": 57,
  "equipmentType": "1 Ton Downflow Evap. Coil",
  "createdDateTime": "2026-05-01T11:13:45",
  "warrantyStart": "2026-05-01",
  "warrantyEnd": "2026-05-30",
  "laborWarrantyStart": "2026-05-01",
  "laborWarrantyEnd": "2026-05-28",
  "installDate": "2026-05-23"
}
```

Dates without time are formatted `yyyy-MM-dd`.

#### `POST ?resource=equipment&op=create`

JSON body:

| Field                | Type                | Required | Notes                                                     |
| -------------------- | ------------------- | -------- | --------------------------------------------------------- |
| `customerId`         | string              | yes      |                                                           |
| `customerGuid`       | string (GUID)       | yes      |                                                           |
| `siteId`             | int                 | yes      | `0` allowed                                               |
| `make`               | string              | no       | Defaults to `""`                                          |
| `model`              | string              | no       |                                                           |
| `notes`              | string              | no       |                                                           |
| `equipmentTypeId`    | int                 | no       | FK to `tbl_EquipmentType`. Fetch via `equipmentTypes` op. |
| `barcode`            | string              | no       |                                                           |
| `serialNumber`       | string              | no       |                                                           |
| `warrantyStart`      | string `yyyy-MM-dd` | no       |                                                           |
| `warrantyEnd`        | string `yyyy-MM-dd` | no       |                                                           |
| `laborWarrantyStart` | string `yyyy-MM-dd` | no       |                                                           |
| `laborWarrantyEnd`   | string `yyyy-MM-dd` | no       |                                                           |
| `installDate`        | string `yyyy-MM-dd` | no       |                                                           |

Returns `{"success":true,"id":1091}`.

#### `POST ?resource=equipment&op=update`

JSON body: same shape as `create` plus `id` (the row's id) and `siteId` (rechecked in WHERE). All field updates are applied unconditionally. Returns 404 if the row isn't owned by this `companyId` (cross-tenant safety).

#### `POST ?resource=equipment&op=delete`

JSON body: `{ id }`. Returns 404 if not owned by this `companyId`.

#### `GET ?resource=equipment&op=equipmentTypes`

Returns the global equipment-type catalog. No customer / site filter. `companyId` is still required for auth uniformity but isn't used in the SQL (the table is shared across companies).

```bash
curl -H "X-Api-Key: $KEY" \
  "$BASE?resource=equipment&op=equipmentTypes&companyId=14590"
```

Response items:

```json
{
  "id": "57",
  "typeName": "1 Ton Downflow Evap. Coil",
  "createdBy": "ProImport",
  "updatedBy": "anordin",
  "createdDateTime": "2014-12-17T17:02:07",
  "updateDateTime": "2014-12-17T17:03:14"
}
```

> **Known data issue on live (2026-05-20):** `tbl_EquipmentType` has 29 rows duplicated, so this endpoint currently returns 58 items where 29 are distinct. Mobile dev: dedupe by `id` until the DB is cleaned up.

---

## 6. End-to-end example — record a service visit

Round-trip a single appointment's mobile interactions:

```bash
KEY="fapro_a8f3k29dm4c7p1r6w9q2x5y8b3n7t1v4z6h0j2l5"
BASE="https://mxp.myserviceforce.com/fsm/FaProMobile.ashx"
CID="14590"; CUSTID="242384"; SID="1452"; APPT="197"
CGUID="93C735B4-0DF3-4968-83D8-D833E629A79E"

# 1. add a note from the field
curl -X POST -H "X-Api-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"customerId":"'$CUSTID'","siteId":'$SID',"description":"Filter replaced. Air flow normal.","reference":"visit-'$APPT'"}' \
  "$BASE?resource=notes&op=create&companyId=$CID"

# 2. upload a before-photo
curl -X POST -H "X-Api-Key: $KEY" \
  -F "customerId=$CUSTID" -F "siteId=$SID" -F "appointmentId=$APPT" \
  -F "reference=before" -F "file=@before.jpg;type=image/jpeg" \
  "$BASE?resource=pictures&op=create&companyId=$CID"

# 3. attach a service report PDF
curl -X POST -H "X-Api-Key: $KEY" \
  -F "customerId=$CUSTID" -F "siteId=$SID" -F "appointmentId=$APPT" \
  -F "reference=service-report" -F "file=@report.pdf;type=application/pdf" \
  "$BASE?resource=files&op=create&companyId=$CID"

# 4. register replaced equipment
curl -X POST -H "X-Api-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"customerId":"'$CUSTID'","customerGuid":"'$CGUID'","siteId":'$SID',"make":"Trane","model":"XR17","equipmentTypeId":57,"serialNumber":"SN-NEW","installDate":"2026-05-20"}' \
  "$BASE?resource=equipment&op=create&companyId=$CID"
```

---

## 7. Errors mobile dev should explicitly handle

| Scenario                                                   | Status | Body                                                                                                                                  |
| ---------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| No API key / wrong key                                     | 401    | `{"success":false,"error":"Unauthorized"}`                                                                                            |
| `companyId` missing                                        | 400    | `{"success":false,"error":"Missing companyId"}`                                                                                       |
| Unknown `resource`                                         | 400    | `{"success":false,"error":"Unknown resource '…'. Expected: notes \| pictures \| files \| equipment"}`                                 |
| Unknown `op` for a resource                                | 400    | `{"success":false,"error":"Unknown op for notes. Expected: list \| create \| createBatch \| update \| delete"}`                       |
| Batch `items[]` missing / empty / too big                  | 400    | `{"success":false,"error":"items[] is empty"}` etc. — for `createBatch`. Per-item errors are returned inside `items[]` with HTTP 200. |
| Wrong HTTP method (e.g. `GET` to `create`)                 | 405    | `{"success":false,"error":"Use POST"}`                                                                                                |
| Required field missing                                     | 400    | e.g. `{"success":false,"error":"Missing customerId, siteId or description"}`                                                          |
| `update` / `delete` of a row not owned by this `companyId` | 404    | `{"success":false,"error":"<Resource> not found or not owned by this company"}`                                                       |
| File upload >25 MB (pictures) / >50 MB (files)             | 400    | `{"success":false,"error":"File exceeds … MB limit"}`                                                                                 |
| Unhandled server exception                                 | 500    | `{"success":false,"error":"Server error: …"}`                                                                                         |

All errors come back with `application/json` content type — no IIS HTML pages.

---

## 8. Notes for the mobile dev

- **Don't cache the API key in plaintext on the device** — read it from secure storage. It grants access to every company's data.
- **`appointmentId` is optional** on note/picture/file create today, but please pass it whenever the action happens in an appointment context. The `tbl_Note.AppointmentId` / `tbl_Pictures.AppointmentId` / `tbl_Files.AppointmentId` columns drive the web UI's "Appointment ID" column on the Notes/Pictures/Files tabs.
- **`siteId=0` is valid** — it means the customer's default site (rows where `tbl_Appointment.SiteID=0` and `tbl_Customer` has no explicit site row). Don't reject it client-side.
- **Pictures vs files** is a storage decision (disk vs DB), not a content decision. Image-type uploads can technically go through either; convention is that user-visible photos go to `pictures` and PDFs / docs go to `files`.
- **Multipart uploads** must use a real multipart body (`Content-Type: multipart/form-data; boundary=…`). Base64-in-JSON is not supported here (that's the web's path, not the mobile path).
- **Date strings**: API returns `yyyy-MM-ddTHH:mm:ss` for timestamps, `yyyy-MM-dd` for date-only equipment fields. Send equipment dates back in the same `yyyy-MM-dd` form.
- **Verify cross-tenant scoping in QA**: try sending a wrong `companyId` for an existing equipment id — must return 404, not silently succeed. (This is a regression-risk area.)

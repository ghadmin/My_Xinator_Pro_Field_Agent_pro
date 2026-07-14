# Items, Item Groups & Item Bundles API — Mobile Integration Guide

How a mobile app lists items, and creates/reads/updates/deletes **item groups** and **item
bundles**. All endpoints live on the `DeviceService` ASMX service and return JSON.

> Transport conventions (base URL, `POST` + `application/json`, **no `d` wrapper**, auth) are the
> same as the Signature API — see `SignatureApi-MobileIntegration.md` §1. In short:
> - `POST https://<your-host>/Services/DeviceService.asmx/<MethodName>`
> - `Content-Type: application/json`, body = one JSON object with **exact, case-sensitive** keys
> - the response body **is** the payload (no `{ "d": ... }` envelope)

---

## Concept model

- **Item** — a sellable product/service (`Items`). Items are the atoms.
- **Item Group** — a named collection of items (`tbl_ItemGroups` + mapping). Read/edit as a unit.
- **Item Bundle** — same shape as a group, stored separately (`ItemBundle`). Use for
  package/kit-style groupings.

Groups and bundles are **structurally identical** (same fields, same paging). The only differences
are the endpoint names and the name field (`GroupName` vs `BundleName`).

---

# 1. Items

### 1.1 List items (paged)

```
POST /Services/DeviceService.asmx/GetAllItemList
```

**Body:**

| Field        | Type   | Required | Notes |
|--------------|--------|----------|-------|
| `companyId`  | string | ✅       | Tenant/company id |
| `pageNumber` | int    | optional | 1-based. Ignored when not paging |
| `pageSize`   | int    | optional | Page size. **`0` (or omit) = return ALL items** (legacy behaviour) |

**Paging rules:**
- `pageSize > 0` → returns that page, ordered by `Name`.
- `pageSize <= 0` → returns **every** item for the company (no paging).
- `TotalItems` in the response is the **full** match count (independent of the page), so you can
  build a pager: `totalPages = ceil(TotalItems / pageSize)`.

**Example request (page 1, 20 per page):**

```json
{ "companyId": "ACME", "pageNumber": 1, "pageSize": 20 }
```

**Response — `ItemsPage`:**

```json
{
  "Items": [
    {
      "Id": "1001",
      "Name": "Oil Filter",
      "Description": "Standard oil filter",
      "Barcode": "0123456789",
      "ItemTypeId": 2,
      "Price": 14.99,
      "Location": "A-12",
      "IsTaxable": true,
      "CompanyId": "ACME",
      "IsDeleted": false,
      "QboId": 5567,
      "PO": false
    }
  ],
  "PageNumber": 1,
  "PageSize": 20,
  "TotalItems": 137
}
```

> When `pageSize <= 0` (return all), `PageNumber` is `1` and `PageSize` is `0` in the response.

**The `Item` object:**

| Field         | Type            | Notes |
|---------------|-----------------|-------|
| `Id`          | string          | Item id |
| `Name`        | string          | |
| `Description` | string          | |
| `Barcode`     | string          | |
| `ItemTypeId`  | int             | |
| `Price`       | decimal         | |
| `Location`    | string          | |
| `IsTaxable`   | bool            | |
| `CompanyId`   | string          | |
| `IsDeleted`   | bool            | Soft-delete flag |
| `QboId`       | int \| null     | QuickBooks id, if synced |
| `PO`          | bool            | |

> There is **no** standalone create/update/delete item endpoint on this service. Items are listed
> here and organized via **groups** and **bundles** below.

---

# 2. Item Groups

### 2.1 List groups (names + counts)

```
POST /Services/DeviceService.asmx/GetItemGroups
```

**Body:**

| Field       | Type   | Required |
|-------------|--------|----------|
| `companyId` | string | ✅       |

**Response —** array of groups. `Items` is **not** populated here (use §2.2 for that);
`ItemCount` gives the number of active items in the group.

```json
[
  { "Id": 3, "GroupName": "Filters", "Description": "All filters",
    "ItemCount": 12, "CompanyId": "ACME", "ItemIds": [], "Items": [],
    "PageNumber": 0, "PageSize": 0, "TotalItems": 0 }
]
```

### 2.2 Get one group with its items (paged)

```
POST /Services/DeviceService.asmx/GetItemGroupById
```

**Body:**

| Field        | Type   | Required | Notes |
|--------------|--------|----------|-------|
| `id`         | int    | ✅       | Group id |
| `companyId`  | string | ✅       | |
| `pageNumber` | int    | ✅       | 1-based (defaults to 1 if `<= 0`) |
| `pageSize`   | int    | ✅       | Defaults to 20 if `<= 0` |

**Response — `ItemGroup`** (its `Items` array is the requested page; `TotalItems` is the full
member count). Returns `null` if the group doesn't exist.

```json
{
  "Id": 3,
  "GroupName": "Filters",
  "Description": "All filters",
  "ItemCount": 0,
  "CompanyId": "ACME",
  "ItemIds": ["1001", "1002"],
  "Items": [ { "Id": "1001", "Name": "Oil Filter", "...": "..." } ],
  "PageNumber": 1,
  "PageSize": 20,
  "TotalItems": 12
}
```

### 2.3 Create / update a group

Same endpoint for both: send `Id = 0` (or omit) to **create**, or a real `Id` to **update**.
The item membership is **rebuilt** from `ItemIds` on every save.

```
POST /Services/DeviceService.asmx/SaveItemGroup
```

**Body:**

| Field       | Type          | Required | Notes |
|-------------|---------------|----------|-------|
| `itemGroup` | ItemGroup     | ✅       | See fields below |
| `userId`    | string        | optional | Audit user; defaults to `"FSM"` if empty |

**`itemGroup` fields that matter:**

| Field         | Type          | Notes |
|---------------|---------------|-------|
| `Id`          | int           | `0`/omit = create; `> 0` = update |
| `GroupName`   | string        | **required**; must be unique per company (case-insensitive) |
| `Description` | string        | optional |
| `CompanyId`   | string        | **required** |
| `ItemIds`     | string[]      | The full set of item ids to belong to the group (membership is replaced) |

**Example (create):**

```json
{
  "itemGroup": {
    "Id": 0,
    "GroupName": "Filters",
    "Description": "All filters",
    "CompanyId": "ACME",
    "ItemIds": ["1001", "1002", "1003"]
  },
  "userId": "tech_045"
}
```

**Response — `StringResult`:**

```json
{ "Status": "success", "Response": "..." }
```

- `Status` is `"success"` or `"error"`.
- On failure, `Response` starts with `"Error:"`, e.g.
  `"Error: An Item Group with this name already exists."`,
  `"Error: Group Name is required."`, `"Error: CompanyId is required."`.

➡️ **Check `Status === "success"`** before treating the save as done.

### 2.4 Delete a group

```
POST /Services/DeviceService.asmx/DeleteItemGroup
```

**Body:**

| Field       | Type   | Required |
|-------------|--------|----------|
| `id`        | int    | ✅       |
| `companyId` | string | ✅       |

**Response — `StringResult`** (same shape as §2.3).

---

# 3. Item Bundles

Bundles mirror groups exactly. Field name is `BundleName` (instead of `GroupName`).

### 3.1 List bundles

```
POST /Services/DeviceService.asmx/GetBundles
```

**Body:** `{ "companyId": "ACME" }`

**Response —** array of `ItemBundle` (names + `ItemCount`; `Items` not populated).

```json
[
  { "Id": 7, "BundleName": "Starter Kit", "Description": "Intro package",
    "ItemCount": 4, "CompanyId": "ACME", "ItemIds": [], "Items": [],
    "PageNumber": 0, "PageSize": 0, "TotalItems": 0 }
]
```

> **Error behaviour differs from groups:** on a server error this endpoint returns **HTTP 500**
> with body `{ "error": "<message>" }` instead of an empty array — so you can distinguish
> "no bundles" (`[]`) from "server failure" (500).

### 3.2 Get one bundle with its items (paged)

> ⚠️ **Note the method name spelling: `GeItemsByBundleId`** (missing the "t" in "Get"). Use it
> exactly as written.

```
POST /Services/DeviceService.asmx/GeItemsByBundleId
```

**Body:**

| Field        | Type   | Required | Notes |
|--------------|--------|----------|-------|
| `id`         | int    | ✅       | Bundle id |
| `companyId`  | string | ✅       | |
| `pageNumber` | int    | ✅       | 1-based |
| `pageSize`   | int    | ✅       | |

**Response — `ItemBundle`** (paged `Items`, full `TotalItems`), or `null` if not found. On a real
server error: HTTP 500 with `{ "error": "..." }`.

```json
{
  "Id": 7,
  "BundleName": "Starter Kit",
  "Description": "Intro package",
  "ItemCount": 0,
  "CompanyId": "ACME",
  "ItemIds": ["1001", "1004"],
  "Items": [ { "Id": "1001", "Name": "Oil Filter", "...": "..." } ],
  "PageNumber": 1,
  "PageSize": 20,
  "TotalItems": 4
}
```

### 3.3 Create / update a bundle

```
POST /Services/DeviceService.asmx/SaveBundle
```

**Body:**

| Field    | Type        | Required | Notes |
|----------|-------------|----------|-------|
| `bundle` | ItemBundle  | ✅       | `Id = 0` create, `> 0` update; `BundleName` + `CompanyId` required; `ItemIds` replaces membership |
| `userId` | string      | optional | Audit user |

**Example (create):**

```json
{
  "bundle": {
    "Id": 0,
    "BundleName": "Starter Kit",
    "Description": "Intro package",
    "CompanyId": "ACME",
    "ItemIds": ["1001", "1004"]
  },
  "userId": "tech_045"
}
```

**Response — `StringResult`** (`Status` = `"success"`/`"error"`; `Response` starts with `"Error:"`
on failure).

### 3.4 Delete a bundle

```
POST /Services/DeviceService.asmx/DeleteBundle
```

**Body:** `{ "id": 7, "companyId": "ACME" }`

**Response — `StringResult`.**

---

# 4. Shared response shapes

**`StringResult`** (save/delete for groups & bundles):

| Field      | Type   | Notes |
|------------|--------|-------|
| `Status`   | string | `"success"` or `"error"` |
| `Response` | string | Message; starts with `"Error:"` on failure |

**`ItemGroup` / `ItemBundle`** (identical except the name field):

| Field                     | Type      | Notes |
|---------------------------|-----------|-------|
| `Id`                      | int       | |
| `GroupName` / `BundleName`| string    | |
| `Description`             | string    | |
| `ItemCount`               | int       | Populated by the list endpoints (§2.1 / §3.1) |
| `CompanyId`               | string    | |
| `ItemIds`                 | string[]  | Member item ids |
| `Items`                   | Item[]    | Populated only by the "get one, paged" endpoints |
| `PageNumber`              | int       | Echoed page number |
| `PageSize`                | int       | Echoed page size |
| `TotalItems`              | int       | Full member count (for pager math) |

---

# 5. Error handling summary

| Endpoint group | Success signal | Failure signal |
|----------------|----------------|----------------|
| `GetAllItemList`, `GetItemGroups`, `GetItemGroupById` | HTTP 200 + JSON body | HTTP 5xx / ASP.NET error body |
| `SaveItemGroup`, `DeleteItemGroup`, `SaveBundle`, `DeleteBundle` | `Status === "success"` | `Status === "error"`, `Response` = `"Error: ..."` |
| `GetBundles`, `GeItemsByBundleId` | HTTP 200 + JSON | **HTTP 500 + `{ "error": "..." }`** |

➡️ For save/delete, **do not** rely on HTTP 200 alone — inspect `Status`.

---

# 6. Checklist

- [ ] Confirm base URL / virtual path and auth with the backend team.
- [ ] Use exact, case-sensitive JSON keys (`companyId`, `pageNumber`, `itemGroup`, `BundleName`, …).
- [ ] Remember `GeItemsByBundleId` is spelled without the "t".
- [ ] For `GetAllItemList`, send `pageSize > 0` to page; `0`/omit returns everything.
- [ ] Build pagers from `TotalItems`, not the length of the returned page.
- [ ] For saves, treat only `Status === "success"` as success and surface `Response` on error.
- [ ] For bundle reads, handle HTTP 500 + `{ "error": ... }` distinctly from an empty result.

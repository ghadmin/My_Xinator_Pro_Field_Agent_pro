# Smart Field PDF Form Filling - Web Implementation

## Overview

This is a complete web-based implementation of the Smart Field PDF Form Filling system, following the specifications from the PDF documentation:

- **Smart Field Issue Solution.pdf** - Smart field data parsing and lookup
- **PDF Implementation Details.pdf** - Proper view hierarchy and field placement

## Features

- ✅ Proper smart field value lookup by `field.id` (not `smartFieldSource`)
- ✅ Correct view hierarchy: ScrollContainer → PageContainer → PageBitmap + Overlay
- ✅ Percentage-based field positioning using the exact math from the PDF
- ✅ No scroll listeners needed - fields scroll automatically with their parent
- ✅ Smart field data parsing from API response
- ✅ Form validation and progress tracking
- ✅ Signature capture with touch support
- ✅ Responsive design for mobile and desktop
- ✅ Parts table support with dynamic rows

## File Structure

```
web-pdf-forms/
├── index.html              # Main HTML file
├── css/
│   └── pdf-form.css        # Styles following PDF implementation guide
├── js/
│   ├── app.js              # Main application controller
│   ├── smart-field-parser.js  # Smart field data parsing
│   ├── pdf-form-renderer.js   # PDF rendering with proper view hierarchy
│   ├── signature-pad.js        # Signature capture
│   └── pdf-lib.min.js          # PDF.js library (add separately)
└── README.md              # This file
```

## Key Implementation Details

### 1. Smart Field Parsing (smart-field-parser.js)

Following the **Smart Field Issue Solution PDF**:

```javascript
// Parse smartFieldData JSON string from API
const smartFieldData = JSON.parse(form.smartFieldData);

// Look up by field.id (e.g., "pdf_1776450913261_56q93m")
// NOT by smartFieldSource (e.g., "system.CompanyName")
const value = smartFieldValues[field.id];
```

**Key points:**
- `smartFieldData` is a sibling property to `template.structure`
- Both are JSON strings that must be parsed
- Values are keyed by `field.id`

### 2. View Hierarchy (pdf-form.css)

Following the **PDF Implementation Details PDF**:

```css
/* ScrollContainer - overflow: auto */
.pdfb-canvas-inner {
    flex: 1;
    overflow: auto;
}

/* PageContainer - position: relative */
.pdfb-page {
    position: relative;
}

/* Overlay - position: absolute, top: 0, left: 0 */
.pdfb-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}
```

**Benefits:**
- Fields are children of the page container, not the scrollview
- Scrolling works automatically without JavaScript
- No scroll desync issues

### 3. Field Placement Math (pdf-form-renderer.js)

Following the **PDF Implementation Details PDF**:

```javascript
// Position is stored as fractions (xPct, yPct, wPct, hPct)
// Convert to pixels at render time
const boxLeftPx = pageWidth * (field.position.xPct / 100);
const boxTopPx = pageHeight * (field.position.yPct / 100);
const boxWidthPx = pageWidth * (field.position.wPct / 100);
const boxHeightPx = pageHeight * (field.position.hPct / 100);
```

## API Integration

### Expected API Response Structure

```json
{
  "success": true,
  "count": 1,
  "items": [
    {
      "queueId": 123,
      "formInstanceId": 456,
      "appointmentId": "789",
      "templateId": 57,
      "customerId": "customer-123",
      "template": {
        "id": 57,
        "name": "Service Form",
        "structure": "{\"fields\":[{\"id\":\"pdf_1776450913261_56q93m\",\"type\":\"smartfield\",\"smartFieldSource\":\"system.CompanyName\",\"position\":{\"xPct\":10,\"yPct\":15,\"wPct\":30,\"hPct\":5},\"page\":1}]}"
      },
      "smartFieldData": "{\"pdf_1776450913261_56q93m\":\"msProDemo\",\"pdf_1776450936990_00x6c4\":\"John Doe\"}"
    }
  ]
}
```

### API Endpoints

```
GET /api/forms/template/{templateId}?companyId={companyId}
GET /api/forms/smart-fields/{formId}?companyId={companyId}
GET /api/forms/pdf/{templateId}?companyId={companyId}
POST /api/forms/submit
```

## Usage

### 1. Include Dependencies

Add PDF.js library to your project:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
```

Or download and place in `js/pdf-lib.min.js`

### 2. Open the Application

Simply open `index.html` in a web browser:

- **Demo mode**: Opens with sample data
- **API mode**: Add URL parameters `?formId=123&templateId=57`

### 3. Form Submission

The form submits with the following structure:

```json
{
  "formInstanceId": "123",
  "templateId": "57",
  "appointmentId": "789",
  "responses": [
    {
      "fieldId": "pdf_1776450913261_56q93m",
      "label": "Company Name",
      "type": "smartfield",
      "value": "msProDemo",
      "position": {"xPct": 10, "yPct": 15, "wPct": 30, "hPct": 5, "page": 1}
    }
  ],
  "submittedAt": "2024-01-15T10:30:00.000Z"
}
```

## Customization

### Styling

Edit `css/pdf-form.css` to match your brand colors:

```css
/* Header gradient */
.form-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Button colors */
.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

### API Configuration

Update the API endpoints in `js/app.js`:

```javascript
async loadFromApi(formId, templateId) {
    // Update these URLs to match your API
    const templateResponse = await fetch(`/api/forms/template/${templateId}...`);
    const smartFieldResponse = await fetch(`/api/forms/smart-fields/${formId}...`);
    const pdfResponse = await fetch(`/api/forms/pdf/${templateId}...`);
}
```

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari 14+, Chrome Android)

## Technical Highlights

### Why This Implementation Works

1. **Correct Smart Field Lookup**
   - Uses `field.id` instead of `smartFieldSource`
   - Matches the exact behavior specified in the PDF

2. **Proper View Hierarchy**
   - ScrollContainer → PageContainer → PageBitmap + Overlay
   - Fields are children of the overlay, not the scrollview
   - No scroll listeners needed

3. **Percentage-Based Positioning**
   - Field positions stored as fractions (xPct, yPct, wPct, hPct)
   - Converted to pixels at render time
   - Matches web implementation exactly

4. **Automatic Scrolling**
   - Fields scroll with their parent page container
   - No JavaScript scroll listeners
   - Smooth, native scrolling performance

## Testing

To test the implementation:

1. Open `index.html` in demo mode (no parameters)
2. Fill out the form fields
3. Check the browser console for form data
4. Click "Submit Form" to see the submission structure

## License

This implementation follows the specifications provided in the PDF documentation.

## Support

For issues or questions, refer to:
- Smart Field Issue Solution.pdf
- PDF Implementation Details.pdf

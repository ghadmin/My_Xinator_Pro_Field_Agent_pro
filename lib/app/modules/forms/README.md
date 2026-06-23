# Dynamic PDF Form System

A production-ready Flutter UI system for rendering interactive forms over PDF pages with JSON-based configuration.

## Overview

This system provides a complete solution for dynamic form filling in field service applications. It renders PDF pages as backgrounds and overlays interactive form fields at precise positions using percentage-based coordinates.

## Features

- **Multi-page PDF support** with smooth vertical scrolling
- **7 field types**: Text, Textarea, Dropdown, Checkbox, Signature, Smart Field, Parts Table
- **Responsive positioning** using percentage-based coordinates
- **Real-time validation** with user-friendly error messages
- **Progress tracking** showing completion percentage
- **Offline-capable** design with local state management
- **Production-ready** error handling and edge cases

## File Structure

```
lib/app/modules/forms/
├── models/
│   └── form_field_model.dart          # Data models for forms and fields
├── widgets/
│   ├── dynamic_pdf_form_widget.dart   # Main form renderer
│   ├── form_field_widgets.dart        # Individual field widgets
│   ├── signature_pad_widget.dart      # Signature capture UI
│   └── dynamic_pdf_form_example.dart  # Usage example
├── views/
│   ├── forms_inbox_view.dart          # Forms list (existing)
│   └── dynamic_form_filling_view.dart # Form filling screen
└── helpers/
    └── pdf_integration_helper.dart    # PDF rendering adapters
```

## Quick Start

### 1. Prepare Your Form Template JSON

```json
{
  "pdfPath": "service_form.pdf",
  "totalPages": 2,
  "fields": [
    {
      "id": "customer_name",
      "type": "text",
      "header": "Customer Name",
      "position": {
        "xPct": 10,
        "yPct": 15,
        "wPct": 35,
        "hPct": 8
      },
      "page": 1
    },
    {
      "id": "service_type",
      "type": "dropdown",
      "header": "Service Type",
      "position": {"xPct": 10, "yPct": 25, "wPct": 30, "hPct": 8},
      "page": 1,
      "dropdownOptions": ["Install", "Repair", "Maintenance"]
    }
  ]
}
```

### 2. Parse and Use

```dart
import 'package:flutter/material.dart';
import '../modules/forms/models/form_field_model.dart';
import '../modules/forms/views/dynamic_form_filling_view.dart';

// Parse JSON template
final template = FormTemplateModel.fromJson(jsonData);

// Prepare smart field values (auto-filled data)
final smartFields = {
  'technician_name': 'John Doe',
  'technician_id': 'TECH-001',
  'date': DateTime.now().toString(),
};

// Navigate to form
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DynamicFormFillingView(
      formId: 'form_001',
      formTitle: 'Service Installation Form',
      template: template,
      smartFieldValues: smartFields,
      pdfBytes: pdfFileBytes, // Load PDF bytes from your source
    ),
  ),
);
```

## Field Types Reference

### 1. Text Field
```json
{
  "id": "field1",
  "type": "text",
  "header": "Name",
  "position": {"xPct": 10, "yPct": 10, "wPct": 30, "hPct": 8},
  "page": 1
}
```

### 2. Textarea (Multiline)
```json
{
  "id": "field2",
  "type": "textarea",
  "header": "Description",
  "position": {"xPct": 10, "yPct": 20, "wPct": 50, "hPct": 15},
  "page": 1
}
```

### 3. Dropdown
```json
{
  "id": "field3",
  "type": "dropdown",
  "header": "Category",
  "position": {"xPct": 10, "yPct": 40, "wPct": 25, "hPct": 8},
  "page": 1,
  "dropdownOptions": ["Option A", "Option B", "Option C"]
}
```

### 4. Checkbox
```json
{
  "id": "field4",
  "type": "checkbox",
  "header": "I agree to terms",
  "position": {"xPct": 10, "yPct": 50, "wPct": 40, "hPct": 8},
  "page": 1
}
```

### 5. Signature
```json
{
  "id": "field5",
  "type": "signature",
  "header": "Customer Signature",
  "position": {"xPct": 10, "yPct": 70, "wPct": 35, "hPct": 15},
  "page": 1
}
```

### 6. Smart Field (Auto-filled)
```json
{
  "id": "field6",
  "type": "smartfield",
  "header": "Technician",
  "position": {"xPct": 55, "yPct": 10, "wPct": 30, "hPct": 8},
  "page": 1,
  "smartFieldSource": "technician_name"
}
```

### 7. Parts Table
```json
{
  "id": "field7",
  "type": "partstable",
  "header": "Parts Used",
  "position": {"xPct": 10, "yPct": 20, "wPct": 80, "hPct": 50},
  "page": 2,
  "maxRows": 10
}
```

## Positioning System

Fields are positioned using percentage values relative to the PDF page:

- **xPct**: Distance from left edge (0-100)
- **yPct**: Distance from top edge (0-100)
- **wPct**: Width as percentage of page width (0-100)
- **hPct**: Height as percentage of page height (0-100)

This ensures consistent positioning across different screen sizes.

## Integration with Existing Forms

### Update FormsController

Add these methods to your existing `FormsController`:

```dart
// In forms_controller.dart

final Rx<Map<String, dynamic>> currentFormData = {}.obs;

Future<void> openDynamicForm(FormQueueItem form) async {
  try {
    // Fetch form template JSON from your API
    final templateData = await formsApiService.getFormTemplate(form.template.id);
    final template = FormTemplateModel.fromJson(templateData);

    // Fetch PDF bytes
    final pdfBytes = await formsApiService.getFormPdf(form.template.id);

    // Prepare smart field values from appointment/context
    final smartFields = {
      'technician_name': MySharedPref.getUserName(),
      'technician_id': MySharedPref.getUserID(),
      'appointment_id': form.appointmentId,
      // Add other smart fields as needed
    };

    // Navigate to form
    await Get.to(() => DynamicFormFillingView(
      formId: form.queueId,
      formTitle: form.template.name,
      formDescription: form.template.description,
      template: template,
      smartFieldValues: smartFields,
      pdfBytes: pdfBytes,
    ));

  } catch (e) {
    Get.snackbar('Error', 'Failed to load form: $e');
  }
}

Future<void> submitFormData(String formId, Map<String, dynamic> data) async {
  try {
    await formsApiService.submitForm(formId, data);
    Get.snackbar('Success', 'Form submitted successfully');
    await pollPendingForms(MySharedPref.getResourceID()!);
  } catch (e) {
    Get.snackbar('Error', 'Failed to submit form: $e');
  }
}
```

### Update FormsInboxView

Modify the form card tap handler:

```dart
// In forms_inbox_view.dart

SplashContainer(
  onPressed: () async {
    await controller.openDynamicForm(form);
  },
  // ... rest of your card widget
)
```

## PDF Rendering Integration

### Option 1: Using pdfx Package

Add to `pubspec.yaml`:

```yaml
dependencies:
  pdfx: ^2.0.0
```

Update the PDF adapter in `pdf_integration_helper.dart`:

```dart
dynamic _tryImportPdfx() {
  try {
    // Uncomment when pdfx is added:
    // import 'package:pdfx/pdfx.dart' as pdfx;
    // return pdfx;
  } catch (e) {
    return null;
  }
}
```

### Option 2: Using syncfusion_flutter_pdf

Add to `pubspec.yaml`:

```yaml
dependencies:
  syncfusion_flutter_pdf: ^24.0.0
```

## Validation Rules

The system validates:

1. **Required fields**: Fields with "required" in header name
2. **Signatures**: All signature fields must be filled
3. **Parts tables**: Must have at least one row
4. **Custom validation**: Add your rules in `_validateForm()`

## State Management

The form maintains its state internally:

```dart
// Access form data
final formData = _formData; // Map<String, dynamic>

// Listen to changes
onFormChanged: (data) {
  print('Form updated: $data');
}
```

## Styling Customization

### Theme Colors

Edit your theme files to customize form appearance:

```dart
// In light_theme_colors.dart
static const Color formBackgroundColor = Color(0xFFFFFFFF);
static const Color formPrimaryColor = Color(0xFF2196F3);
static const Color formErrorColor = Color(0xFFF44336);
```

### Field Styling

Modify `form_field_widgets.dart` to update field appearance:

```dart
// Example: Change text field border
decoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.blue),
  ),
);
```

## Testing

### Unit Test Example

```dart
test('Form field model parses correctly', () {
  final json = {
    'id': 'test_field',
    'type': 'text',
    'position': {'xPct': 10, 'yPct': 10, 'wPct': 30, 'hPct': 8},
    'page': 1
  };

  final field = FormFieldModel.fromJson(json);
  expect(field.id, 'test_field');
  expect(field.type, 'text');
});
```

## Performance Tips

1. **Lazy load PDF pages**: Load pages as user scrolls
2. **Compress PDF images**: Use appropriate DPI (200 is recommended)
3. **Cache rendered pages**: Store rendered page images locally
4. **Optimize field widgets**: Use `const` constructors where possible

## Troubleshooting

### Fields not appearing
- Check page number matches PDF page
- Verify position percentages are valid (0-100)
- Ensure PDF is loaded successfully

### Signature not saving
- Check signature pad returns base64 string
- Verify form data includes signature field

### Validation not working
- Ensure field IDs match between template and data
- Check required field naming convention

## License

This is part of your proprietary application. All rights reserved.

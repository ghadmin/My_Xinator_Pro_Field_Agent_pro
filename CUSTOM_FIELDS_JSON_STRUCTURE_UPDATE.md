# Custom Fields JSON Structure Update

## Overview

Updated the custom fields save/load functionality to use the correct API JSON structure. The `FeildsValue` parameter now expects an **array of objects** with `type`, `value1`, and `value2` properties, instead of simple key-value pairs.

## JSON Structure

### Save Request Format
```json
{
  "AppointmentId": 175,
  "FeildsValue": "[{\"type\":\"Plumbing Equipments\",\"value1\":\"Wrench\",\"value2\":\"Wire\"},{\"type\":\"Check List 1\",\"value1\":\"cvb cvb cvb dfg\",\"value2\":\"\"}]"
}
```

### Parsed Format (for readability)
```json
{
  "AppointmentId": 175,
  "FeildsValue": [
    {
      "type": "Plumbing Equipments",
      "value1": "Wrench",
      "value2": "Wire"
    },
    {
      "type": "Check List 1",
      "value1": "cvb cvb cvb dfg",
      "value2": ""
    }
  ]
}
```

## Field Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | String | The field name (e.g., "Plumbing Equipments", "Customer Name") |
| `value1` | String | The primary field value |
| `value2` | String | Optional secondary value (can be empty string) |

## Field Type Handling

### Text Fields
- **Storage**: `value1` contains the text input
- **Example**: `{"type": "CustomerName", "value1": "John Doe", "value2": ""}`

### Number Fields
- **Storage**: `value1` contains the numeric value as string
- **Example**: `{"type": "Phone", "value1": "555-1234", "value2": ""}`

### Dropdown Fields
- **Storage**: `value1` contains the selected option
- **Example**: `{"type": "Priority", "value1": "High", "value2": ""}`

### Checklist Fields
- **Storage**: `value1` contains comma-separated selected options
- **Storage**: `value2` can contain additional options
- **Example**: `{"type": "Services", "value1": "Repair,Install", "value2": "Maintenance"}`

## Code Changes

### Files Modified

1. **[appointment_details_view.dart:97-182](lib/app/modules/appointment/views/appointment_details_view.dart#L97-L182)**
   - Updated `_loadSavedCustomFields()` to parse array structure
   - Maps `type` field to `fieldName`
   - Handles `value1` and `value2` based on field type

2. **[appointment_details_view.dart:3520-3578](lib/app/modules/appointment/views/appointment_details_view.dart#L3520-L3578)**
   - Updated `_saveCustomFields()` to serialize as array of objects
   - Creates objects with `type`, `value1`, `value2` structure

3. **Documentation Files**
   - [CUSTOM_FIELDS_SAVE_FEATURE.md](CUSTOM_FIELDS_SAVE_FEATURE.md) - Updated examples
   - [SAVE_CUSTOM_FIELD_API_USAGE.md](SAVE_CUSTOM_FIELD_API_USAGE.md) - Updated all code examples

## Implementation Details

### Loading Saved Fields
```dart
// Parse as array of objects
List<dynamic> savedFieldsArray = jsonDecode(fieldsValueJson);

for (var fieldData in savedFieldsArray) {
  String? fieldType = fieldData["type"];
  String? value1 = fieldData["value1"];
  String? value2 = fieldData["value2"];

  // Find matching field definition
  var fieldDef = customFieldsController.allCustomFields.firstWhereOrNull(
    (f) => f.fieldName == fieldType,
  );

  // Create new field instance and set value
  // Handle based on field type (text, number, dropdown, checklist)
}
```

### Saving Fields
```dart
// Collect field values as array of objects
final List<Map<String, dynamic>> fieldsArray = [];
for (var field in customFieldsController.selectedCustomFields) {
  final value = field.getFieldValue();
  if (value != null && value.isNotEmpty) {
    fieldsArray.add({
      "type": field.fieldName,
      "value1": value,
      "value2": "",
    });
  }
}

// Convert to JSON string
final fieldsValue = jsonEncode(fieldsArray);
```

## Benefits

1. ✅ **Matches actual API structure** - No more parsing errors
2. ✅ **Supports complex field types** - Checklist can have multiple values
3. ✅ **Extensible** - Can add more values in the future (value3, value4, etc.)
4. ✅ **Type-safe** - Explicit field type property
5. ✅ **Better data integrity** - Each field is a separate object

## Testing

### Test Case 1: Save and Load Text Fields
```dart
// Save
[
  {"type": "CustomerName", "value1": "John Doe", "value2": ""},
  {"type": "Phone", "value1": "555-1234", "value2": ""}
]

// Load
// Should populate text fields with correct values
```

### Test Case 2: Save and Load Checklist
```dart
// Save
[
  {"type": "Services", "value1": "Repair,Install", "value2": "Maintenance"}
]

// Load
// Should populate checklist with: ["Repair", "Install", "Maintenance"]
```

### Test Case 3: Save Empty Fields
```dart
// Save
[]

// Load
// Should show no custom fields selected
```

## Migration Notes

### Old Format (No Longer Supported)
```json
{
  "CustomerName": "John Doe",
  "Phone": "555-1234"
}
```

### New Format (Required)
```json
[
  {"type": "CustomerName", "value1": "John Doe", "value2": ""},
  {"type": "Phone", "value1": "555-1234", "value2": ""}
]
```

## Related Files

- **Controller**: [custom_fields_controller.dart](lib/app/modules/appointment/controllers/custom_fields_controller.dart)
- **Model**: [custom_field_model.dart](lib/app/modules/appointment/models/custom_field_model.dart)
- **View**: [appointment_details_view.dart](lib/app/modules/appointment/views/appointment_details_view.dart)
- **API URL**: [api_urls.dart:40](lib/app/service/REST/api_urls.dart#L40)

## API Endpoint

```
POST https://testsite.myserviceforce.com/cec/Services/DeviceService.asmx/SaveCustomFeild
```

### Request Body
```json
{
  "AppointmentId": 175,
  "FeildsValue": "[{\"type\":\"FieldName\",\"value1\":\"Value\",\"value2\":\"\"}]"
}
```

### Response
```json
{
  "IsValid": true,
  "Success": true,
  "Message": "Custom field saved successfully"
}
```

## Summary

The custom fields functionality now correctly uses the array-based JSON structure as required by the backend API. Both saving and loading have been updated to handle the `[{"type", "value1", "value2"}]` format.

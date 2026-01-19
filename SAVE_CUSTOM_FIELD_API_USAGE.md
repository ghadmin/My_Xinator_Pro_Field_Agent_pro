# Save Custom Field API - Usage Guide

## API Endpoint
```
POST https://testsite.myserviceforce.com/cec/Services/DeviceService.asmx/SaveCustomFeild
```

## Function Added

### Location
**File:** [lib/app/modules/appointment/controllers/custom_fields_controller.dart](lib/app/modules/appointment/controllers/custom_fields_controller.dart)

### Function Signature
```dart
Future<void> saveCustomFieldToServer({
  required int appointmentId,
  required String fieldsValue,
})
```

### Request Body Parameters
```csharp
// C# API Model (for reference)
public int AppointmentId { get; set; }
public string FeildsValue { get; set; }  // JSON string of field values
```

## Usage Examples

### Example 1: Save Single Custom Field
```dart
// Get the controller
final customFieldsController = Get.find<CustomFieldsController>();

// Prepare custom field values as JSON string (array of objects)
final fieldsValue = jsonEncode([
  {
    "type": "CustomerName",
    "value1": "John Doe",
    "value2": ""
  },
  {
    "type": "PhoneNumber",
    "value1": "555-1234",
    "value2": ""
  }
]);

// Call the API
await customFieldsController.saveCustomFieldToServer(
  appointmentId: 12345,
  fieldsValue: fieldsValue,
);
```

### Example 2: Save Multiple Custom Fields
```dart
// Multiple fields as JSON array
final fieldsValue = jsonEncode([
  {
    "type": "SiteAccessCode",
    "value1": "CODE-123",
    "value2": ""
  },
  {
    "type": "ParkingInstructions",
    "value1": "Park in rear lot",
    "value2": ""
  },
  {
    "type": "EmergencyContact",
    "value1": "Jane Doe - 555-9999",
    "value2": ""
  },
  {
    "type": "SpecialRequirements",
    "value1": "Needs wheelchair access",
    "value2": ""
  }
]);

await customFieldsController.saveCustomFieldToServer(
  appointmentId: 12345,
  fieldsValue: fieldsValue,
);
```

### Example 3: Save with Dynamic Field Array
```dart
// Build field array dynamically
List<Map<String, dynamic>> customFields = [];

// Add fields conditionally
if (hasCustomerNote) {
  customFields.add({
    "type": "CustomerNote",
    "value1": customerNoteController.text,
    "value2": ""
  });
}

if (hasPriority) {
  customFields.add({
    "type": "PriorityLevel",
    "value1": selectedPriority,
    "value2": ""
  });
}

// Convert to JSON string
final fieldsValue = jsonEncode(customFields);

await customFieldsController.saveCustomFieldToServer(
  appointmentId: appointment.id,
  fieldsValue: fieldsValue,
);
```

### Example 4: Save Form Data
```dart
// From a form with text controllers
final fieldsValue = jsonEncode([
  {
    "type": "Field1",
    "value1": textController1.text,
    "value2": ""
  },
  {
    "type": "Field2",
    "value1": textController2.text,
    "value2": ""
  },
  {
    "type": "Field3",
    "value1": dropdownValue,
    "value2": ""
  },
  {
    "type": "Field4",
    "value1": checkboxValue ? "Yes" : "No",
    "value2": ""
  },
  {
    "type": "Field5",
    "value1": dateController.text,
    "value2": ""
  }
]);

await customFieldsController.saveCustomFieldToServer(
  appointmentId: currentAppointmentId,
  fieldsValue: fieldsValue,
);
```

### Example 5: Save Empty Fields (Clear Previous Values)
```dart
// Clear all custom fields for an appointment
final fieldsValue = jsonEncode([]);

await customFieldsController.saveCustomFieldToServer(
  appointmentId: 12345,
  fieldsValue: fieldsValue,
);
```

## Features

### ✅ What the function does:
1. **Checks network connectivity** before making the request
2. **Sends exact API format**: `AppointmentId` + `FeildsValue` (JSON string array)
3. **Shows loading indicator** during the API call
4. **Handles errors** with user-friendly messages
5. **Refreshes the custom fields list** after successful save
6. **Comprehensive logging** for debugging

### ✅ Request Format:
```json
{
  "AppointmentId": 12345,
  "FeildsValue": "[{\"type\":\"Field1\",\"value1\":\"Value1\",\"value2\":\"\"},{\"type\":\"Field2\",\"value1\":\"Value2\",\"value2\":\"\"}]"
}
```

### ✅ Response Handling:
- Success: Shows success toast + refreshes list
- Error: Shows error message from server or generic error
- Network Error: Shows "No network connection" message

### ✅ Error Logging:
The function logs detailed errors:
```
📤 Saving custom field for appointment: 12345
📤 Fields value: {"Field1":"Value1"}
📤 Full request body: {"AppointmentId":12345,"FeildsValue":"{...}"}
✅ Custom field saved successfully: {...}
⚠️ Failed to save custom field: {...}
❌ Error saving custom field: {...}
```

## Expected Response

### Success Response:
```json
{
  "IsValid": true,
  "Success": true,
  "Message": "Custom field saved successfully"
}
```

### Error Response:
```json
{
  "IsValid": false,
  "Message": "Error message here"
}
```

## Important Notes

1. **`FeildsValue` must be a JSON string of an array** - Use `jsonEncode()` to convert your List to string
2. **Format is array of objects**: `[{"type": "FieldName", "value1": "...", "value2": "..."}]`
3. **Appointment ID is required** - Must be a valid integer
4. **The function automatically handles**:
   - Network connectivity check
   - Loading indicator show/hide
   - Error catching and logging
   - Success/error toast messages
   - Refresh of custom fields list

5. **Field types should match your backend custom field definitions**

6. **Loading indicator** is shown/hidden automatically
7. **All errors are caught and logged** with stack traces

8. **`value1`** contains the main field value
9. **`value2`** is optional and can be used for additional values (e.g., second checklist column)

## API URL
**File:** [lib/app/service/REST/api_urls.dart:40](lib/app/service/REST/api_urls.dart#L40)
```dart
static const saveCustomFieldUrl = "$baseUrl/SaveCustomFeild";
```

## Complete Example with Try-Catch

```dart
ElevatedButton(
  onPressed: () async {
    try {
      // Build your custom fields array
      final List<Map<String, dynamic>> fields = [
        {
          "type": "CustomerName",
          "value1": "John Doe",
          "value2": ""
        },
        {
          "type": "Phone",
          "value1": "555-1234",
          "value2": ""
        },
        {
          "type": "Notes",
          "value1": "Important customer",
          "value2": ""
        }
      ];

      // Convert to JSON string
      final fieldsValue = jsonEncode(fields);

      // Save to server
      await customFieldsController.saveCustomFieldToServer(
        appointmentId: appointment.id,
        fieldsValue: fieldsValue,
      );

      // Success is handled by the function (shows toast)
    } catch (e) {
      // Additional error handling if needed
      log("Additional error handling: $e");
    }
  },
  child: Text("Save Custom Fields"),
)
```

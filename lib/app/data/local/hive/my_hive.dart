import 'package:hive_flutter/hive_flutter.dart';

import '../../../../utils/klog.dart';
import '../../../modules/appointment/models/appointment_model.dart';
import '../../../modules/customer/models/customer_model.dart';
import '../../../modules/invoice/models/tax_model.dart';
import '../../../modules/item/models/item_group_model.dart';
import '../../../modules/item/models/item_list_model.dart';
import '../../../modules/settings/models/appointment_status_setting.dart';
import '../../../modules/settings/models/ticket_status_model.dart';

class MyHive {
  // Prevent making an instance of this class
  MyHive._();

  // Hive box to store appointments data
  static late Box<Appointments> _appointmentBox;
  static late Box<CustomerModel> _customerBox;
  static late Box<TicketStatusSettings> _ticketStatusSettingBox;
  static late Box<AppointmentStatusSetting> _appointmentStatusSettingBox;
  static late Box<TaxModel> _taxBox;
  static late Box<ItemListModel> _itemListBox;
  static late Box<ItemGroupModel> _itemGroupListBox;
  static late Box<dynamic> _formsBox;

  // Box name, it's like the table name

  static const String _appointmentBoxName = 'appointments';
  static const String _customerBoxName = 'customers';
  static const String _ticketStatusSettingBoxName = 'ticketStatusSetting';
  static const String _taxBoxName = 'tax';
  static const String _itemListBoxName = 'itemListBox';
  static const String _itemGroupListBoxName = 'itemGroupListBox';
  static const String _appointmentStatusSettingBoxName =
      'appointmentStatusSetting';
  static const String _formsBoxName = 'forms';

  /// Initialize local db (HIVE)
  /// Pass testPath only if you are testing hive
  static Future<void> init({
    Function(HiveInterface)? registerAdapters,
    String? testPath,
  }) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    await registerAdapters?.call(Hive);

    await initAppointmentsBox();
    await initCustomersBox();
    await initTicketStatusSettingBox();
    await initAppointmentStatusSettingBox();
    await initTaxBox();
    await initItemListBox();
    await initItemGroupListBox();
    await initFormsBox();
  }

  /// Initialize appointments box
  static Future<void> initAppointmentsBox() async {
    try {
      _appointmentBox = await Hive.openBox<Appointments>(_appointmentBoxName);
    } catch (error) {
      kLog("Error opening appointmentBox: $error. Deleting and recreating.");
      await Hive.deleteBoxFromDisk(_appointmentBoxName);
      _appointmentBox = await Hive.openBox<Appointments>(_appointmentBoxName);
    }
  }

  /// Initialize customer box
  static Future<void> initCustomersBox() async {
    try {
      _customerBox = await Hive.openBox<CustomerModel>(_customerBoxName);
    } catch (error) {
      kLog("Error opening customerBox: $error. Deleting and recreating.");
      await Hive.deleteBoxFromDisk(_customerBoxName);
      _customerBox = await Hive.openBox<CustomerModel>(_customerBoxName);
    }
  }

  /// Initialize ticketStatusSetting box
  static Future<void> initTicketStatusSettingBox() async {
    try {
      _ticketStatusSettingBox = await Hive.openBox<TicketStatusSettings>(
        _ticketStatusSettingBoxName,
      );
    } catch (error) {
      kLog(
        "Error opening ticketStatusSettingBox: $error. Deleting and recreating.",
      );
      await Hive.deleteBoxFromDisk(_ticketStatusSettingBoxName);
      _ticketStatusSettingBox = await Hive.openBox<TicketStatusSettings>(
        _ticketStatusSettingBoxName,
      );
    }
  }

  /// Initialize appointmentStatusSetting box
  static Future<void> initAppointmentStatusSettingBox() async {
    try {
      _appointmentStatusSettingBox =
          await Hive.openBox<AppointmentStatusSetting>(
            _appointmentStatusSettingBoxName,
          );
    } catch (error) {
      kLog(
        "Error opening appointmentStatusSettingBox: $error. Deleting and recreating.",
      );
      await Hive.deleteBoxFromDisk(_appointmentStatusSettingBoxName);
      _appointmentStatusSettingBox =
          await Hive.openBox<AppointmentStatusSetting>(
            _appointmentStatusSettingBoxName,
          );
    }
  }

  /// Initialize tax box
  static Future<void> initTaxBox() async {
    try {
      _taxBox = await Hive.openBox<TaxModel>(_taxBoxName);
    } catch (error) {
      kLog("Error opening taxBox: $error. Deleting and recreating.");
      await Hive.deleteBoxFromDisk(_taxBoxName);
      _taxBox = await Hive.openBox<TaxModel>(_taxBoxName);
    }
  }

  /// Initialize item List box
  static Future<void> initItemListBox() async {
    try {
      _itemListBox = await Hive.openBox<ItemListModel>(_itemListBoxName);
    } catch (error) {
      kLog(
        "Error opening itemListBox, file might be corrupted. Deleting and recreating: $error",
      );
      await Hive.deleteBoxFromDisk(_itemListBoxName);
      _itemListBox = await Hive.openBox<ItemListModel>(_itemListBoxName);
    }
  }

  /// Initialize item group List box
  static Future<void> initItemGroupListBox() async {
    try {
      _itemGroupListBox = await Hive.openBox<ItemGroupModel>(_itemGroupListBoxName);
    } catch (error) {
      kLog(
        "Error opening itemGroupListBox, file might be corrupted. Deleting and recreating: $error",
      );
      await Hive.deleteBoxFromDisk(_itemGroupListBoxName);
      _itemGroupListBox = await Hive.openBox<ItemGroupModel>(_itemGroupListBoxName);
    }
  }

  /// Initialize forms box
  static Future<void> initFormsBox() async {
    try {
      _formsBox = await Hive.openBox<dynamic>(_formsBoxName);
    } catch (error) {
      kLog("Error opening formsBox: $error. Deleting and recreating.");
      await Hive.deleteBoxFromDisk(_formsBoxName);
      _formsBox = await Hive.openBox<dynamic>(_formsBoxName);
    }
  }

  /// Save all appointments to the database
  static Future<void> saveAllAppointments(
    List<Appointments> appointments,
  ) async {
    try {
      await _appointmentBox.clear();
      await _appointmentBox.addAll(appointments);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all customer to the database
  static Future<void> saveAllCustomers(List<CustomerModel> customers) async {
    try {
      await _customerBox.clear();
      await _customerBox.addAll(customers);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all ticketStatusSetting to the database
  static Future<void> saveAllTicketStatusSetting(
    List<TicketStatusSettings> ticketStatusSetting,
  ) async {
    try {
      await _ticketStatusSettingBox.clear();
      await _ticketStatusSettingBox.addAll(ticketStatusSetting);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all appointmentStatusSetting to the database
  static Future<void> saveAllAppointmentStatusSetting(
    List<AppointmentStatusSetting> appointmentStatusSetting,
  ) async {
    try {
      await _appointmentStatusSettingBox.clear();
      await _appointmentStatusSettingBox.addAll(appointmentStatusSetting);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all tax to the database
  static Future<void> saveTax(List<TaxModel> tax) async {
    try {
      await _taxBox.clear();
      await _taxBox.addAll(tax);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all itemList to the database
  static Future<void> saveItemList(List<ItemListModel> items) async {
    try {
      await _itemListBox.clear();
      await _itemListBox.addAll(items);
    } catch (error) {
      kLog("Error saving appointments: $error");
    }
  }

  /// Save all itemGroupList to the database
  static Future<void> saveItemGroupList(List<ItemGroupModel> itemGroups) async {
    try {
      await _itemGroupListBox.clear();
      await _itemGroupListBox.addAll(itemGroups);
    } catch (error) {
      kLog("Error saving item groups: $error");
    }
  }

  /// Get all appointments from Hive
  static List<Appointments> getAllAppointments() {
    final recipes = _appointmentBox.values.toList();
    return recipes.cast<Appointments>();
  }

  /// Get all customers from Hive
  static List<CustomerModel> getAllCustomers() {
    final customers = _customerBox.values.toList();
    return customers.cast<CustomerModel>();
  }

  /// Get all ticketStatusSetting from Hive
  static List<TicketStatusSettings> getAllTicketStatusSetting() {
    final ticketStatusSetting = _ticketStatusSettingBox.values.toList();
    return ticketStatusSetting.cast<TicketStatusSettings>();
  }

  /// Get all appointmentStatusSetting from Hive
  static List<AppointmentStatusSetting> getAllAppointmentStatusSetting() {
    final appointmentStatusSetting = _appointmentStatusSettingBox.values
        .toList();
    return appointmentStatusSetting.cast<AppointmentStatusSetting>();
  }

  /// Get all tax from Hive
  static List<TaxModel> getAllTax() {
    final tax = _taxBox.values.toList();
    return tax.cast<TaxModel>();
  }

  /// Get all itemList from Hive
  static List<ItemListModel> getAllItemList() {
    final item = _itemListBox.values.toList();
    return item.cast<ItemListModel>();
  }

  /// Get all itemGroupList from Hive
  static List<ItemGroupModel> getAllItemGroups() {
    final itemGroups = _itemGroupListBox.values.toList();
    return itemGroups.cast<ItemGroupModel>();
  }

  /// Save forms data for a specific resource
  static Future<void> saveFormsData(
    String resourceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _formsBox.put(resourceId, data);
      kLog("✅ Saved forms data for resourceId: $resourceId");
    } catch (error) {
      kLog("❌ Error saving forms data: $error");
    }
  }

  /// Get forms data for a specific resource
  static Map<String, dynamic>? getFormsData(String resourceId) {
    try {
      final data = _formsBox.get(resourceId);
      if (data != null && data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (error) {
      kLog("❌ Error getting forms data: $error");
      return null;
    }
  }

  /// Get all forms data
  static Map<String, dynamic> getAllFormsData() {
    try {
      final data = <String, dynamic>{};
      for (final key in _formsBox.keys) {
        final value = _formsBox.get(key);
        if (value != null && value is Map) {
          data[key.toString()] = Map<String, dynamic>.from(value);
        }
      }
      return data;
    } catch (error) {
      kLog("❌ Error getting all forms data: $error");
      return {};
    }
  }

  /// Clear forms data for a specific resource
  static Future<void> clearFormsData(String resourceId) async {
    try {
      await _formsBox.delete(resourceId);
      kLog("✅ Cleared forms data for resourceId: $resourceId");
    } catch (error) {
      kLog("❌ Error clearing forms data: $error");
    }
  }

  /// Clear all forms data
  static Future<void> clearAllFormsData() async {
    try {
      await _formsBox.clear();
      kLog("✅ Cleared all forms data");
    } catch (error) {
      kLog("❌ Error clearing all forms data: $error");
    }
  }

  /// Save form progress data (field values, signatures, etc.)
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [fieldValues] - Map of fieldId -> value (text, base64 signature, etc.)
  static Future<void>   saveFormProgress(
    int formInstanceId,
    Map<String, dynamic> fieldValues, {
    String? appointmentId,
  }) async {
    try {
      final progressKey =
          'form_progress_${appointmentId ?? 'unknown'}_$formInstanceId';
      final progressData = {
        'formInstanceId': formInstanceId,
        'appointmentId': appointmentId,
        'fieldValues': fieldValues,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _formsBox.put(progressKey, progressData);
      kLog(
        "✅ Saved form progress for appointmentId: $appointmentId, formInstanceId: $formInstanceId (${fieldValues.length} fields)",
      );
    } catch (error) {
      kLog("❌ Error saving form progress: $error");
    }
  }

  /// Get saved form progress data
  ///
  /// [formInstanceId] - Unique ID for the form instance
  /// [appointmentId] - The appointment ID to verify match
  /// Returns map of fieldId -> value, or empty map if no saved data exists or IDs don't match
  static Map<String, dynamic> getFormProgress(
    int formInstanceId, {
    String? appointmentId,
  }) {
    try {
      final progressKey =
          'form_progress_${appointmentId ?? 'unknown'}_$formInstanceId';
      final progressData = _formsBox.get(progressKey);

      if (progressData != null && progressData is Map) {
        // Verify appointmentId matches if provided
        if (appointmentId != null) {
          final savedAppointmentId = progressData['appointmentId'];
          if (savedAppointmentId != appointmentId) {
            kLog(
              "⚠️ Appointment ID mismatch: expected $appointmentId, got $savedAppointmentId",
            );
            return {};
          }
        }

        // Convert the Map to ensure String keys
        final Map<String, dynamic> fieldValues = {};
        final rawFieldValues = progressData['fieldValues'];

        if (rawFieldValues != null && rawFieldValues is Map) {
          // Convert each entry to ensure proper typing
          rawFieldValues.forEach((key, value) {
            if (key != null && value != null) {
              fieldValues[key.toString()] = value;
            }
          });
          kLog(
            "✅ Loaded form progress for appointmentId: $appointmentId, formInstanceId: $formInstanceId (${fieldValues.length} saved fields)",
          );
          return fieldValues;
        }
      }

      kLog(
        "⚠️ No saved progress found for appointmentId: $appointmentId, formInstanceId: $formInstanceId",
      );
      return {};
    } catch (error) {
      kLog("❌ Error getting form progress: $error");
      return {};
    }
  }

  /// Clear saved form progress data
  ///
  /// [formInstanceId] - Unique ID for the form instance
  static Future<void> clearFormProgress(int formInstanceId) async {
    try {
      final progressKey = 'form_progress_$formInstanceId';
      await _formsBox.delete(progressKey);
      kLog("✅ Cleared form progress for formInstanceId: $formInstanceId");
    } catch (error) {
      kLog("❌ Error clearing form progress: $error");
    }
  }

  /// Check if form has saved progress
  ///
  /// [formInstanceId] - Unique ID for the form instance
  static bool hasFormProgress(int formInstanceId) {
    try {
      final progressKey = 'form_progress_$formInstanceId';
      final progressData = _formsBox.get(progressKey);
      return progressData != null;
    } catch (error) {
      kLog("❌ Error checking form progress: $error");
      return false;
    }
  }
}

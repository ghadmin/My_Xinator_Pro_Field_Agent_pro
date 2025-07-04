import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:xinator_fsm_pro/app/modules/item/models/item_list_model.dart';

import '../../../modules/appointment/models/appointment_model.dart';
import '../../../modules/customer/models/customer_model.dart';
import '../../../modules/invoice/models/tax_model.dart';
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

  // Box name, it's like the table name

  static const String _appointmentBoxName = 'appointments';
  static const String _customerBoxName = 'customers';
  static const String _ticketStatusSettingBoxName = 'ticketStatusSetting';
  static const String _taxBoxName = 'tax';
  static const String _itemListBoxName = 'itemListBox';
  static const String _appointmentStatusSettingBoxName =
      'appointmentStatusSetting';

  /// Initialize local db (HIVE)
  /// Pass testPath only if you are testing hive
  static Future<void> init(
      {Function(HiveInterface)? registerAdapters, String? testPath}) async {
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
  }

  /// Initialize appointments box
  static Future<void> initAppointmentsBox() async {
    _appointmentBox = await Hive.openBox<Appointments>(_appointmentBoxName);
  }

  /// Initialize customer box
  static Future<void> initCustomersBox() async {
    _customerBox = await Hive.openBox<CustomerModel>(_customerBoxName);
  }

  /// Initialize ticketStatusSetting box
  static Future<void> initTicketStatusSettingBox() async {
    _ticketStatusSettingBox =
        await Hive.openBox<TicketStatusSettings>(_ticketStatusSettingBoxName);
  }

  /// Initialize appointmentStatusSetting box
  static Future<void> initAppointmentStatusSettingBox() async {
    _appointmentStatusSettingBox = await Hive.openBox<AppointmentStatusSetting>(
        _appointmentStatusSettingBoxName);
  }

  /// Initialize tax box
  static Future<void> initTaxBox() async {
    _taxBox = await Hive.openBox<TaxModel>(_taxBoxName);
  }

  /// Initialize item List box
  static Future<void> initItemListBox() async {
    _itemListBox = await Hive.openBox<ItemListModel>(_itemListBoxName);
  }

  /// Save all appointments to the database
  static Future<void> saveAllAppointments(
      List<Appointments> appointments) async {
    try {
      await _appointmentBox.clear();
      await _appointmentBox.addAll(appointments);
    } catch (error) {
      Logger().e("$error");
    }
  }

  /// Save all customer to the database
  static Future<void> saveAllCustomers(List<CustomerModel> customers) async {
    try {
      await _customerBox.clear();
      await _customerBox.addAll(customers);
    } catch (error) {
      Logger().e("$error");
    }
  }

  /// Save all ticketStatusSetting to the database
  static Future<void> saveAllTicketStatusSetting(
      List<TicketStatusSettings> ticketStatusSetting) async {
    try {
      await _ticketStatusSettingBox.clear();
      await _ticketStatusSettingBox.addAll(ticketStatusSetting);
    } catch (error) {
      Logger().e("$error");
    }
  }

  /// Save all appointmentStatusSetting to the database
  static Future<void> saveAllAppointmentStatusSetting(
      List<AppointmentStatusSetting> appointmentStatusSetting) async {
    try {
      await _appointmentStatusSettingBox.clear();
      await _appointmentStatusSettingBox.addAll(appointmentStatusSetting);
    } catch (error) {
      Logger().e("$error");
    }
  }

  /// Save all tax to the database
  static Future<void> saveTax(List<TaxModel> tax) async {
    try {
      await _taxBox.clear();
      await _taxBox.addAll(tax);
    } catch (error) {
      Logger().e("$error");
    }
  }

  /// Save all itemList to the database
  static Future<void> saveItemList(List<ItemListModel> items) async {
    try {
      await _itemListBox.clear();
      await _itemListBox.addAll(items);
    } catch (error) {
      Logger().e("$error");
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
    final appointmentStatusSetting =
        _appointmentStatusSettingBox.values.toList();
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
}

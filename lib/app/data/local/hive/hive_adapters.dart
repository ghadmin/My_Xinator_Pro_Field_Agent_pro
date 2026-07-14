import '../../../modules/appointment/models/appointment_model.dart';
import '../../../modules/sceduling/models/appointment_model.dart' as scheduling_models;
import '../../../modules/customer/models/customer_model.dart';
import '../../../modules/invoice/models/tax_model.dart';
import '../../../modules/item/models/item_list_model.dart';
import '../../../modules/item/models/item_group_model.dart';
import '../../../modules/item/models/item_bundle_model.dart';
import '../../../modules/settings/models/appointment_status_setting.dart';
import '../../../modules/settings/models/ticket_status_model.dart';
import 'my_hive.dart';

class HiveAdapters {
  static Future<void> registerAll() async {
    await MyHive.init(registerAdapters: (hive) {
      hive
        // HiveAdapter for AppointmentsModel
        ..registerAdapter(AppointmentsAdapter())
        ..registerAdapter(InvoicesAdapter())
        ..registerAdapter(ItemsAdapter())
        ..registerAdapter(ServiceTypeAdapter())
        ..registerAdapter(TicketStatusAdapter())
        ..registerAdapter(StatusAdapter())
        ..registerAdapter(CustomerAdapter())
        ..registerAdapter(ResourceAdapter())
        ..registerAdapter(PaymentAdapter())
        ..registerAdapter(SignatureAdapter())
        ..registerAdapter(scheduling_models.PaymentSignatureAdapter())

        // HiveAdapter for TicketStatusSettings
        ..registerAdapter(TicketStatusSettingsAdapter())
        // HiveAdapter for AppointmentStatusSetting
        ..registerAdapter(AppointmentStatusSettingAdapter())
        // HiveAdapter for TaxModel
        ..registerAdapter(TaxModelAdapter())
        // HiveAdapter for CustomerModel
        ..registerAdapter(CustomerModelAdapter())
        // HiveAdapter for ItemListModel
        ..registerAdapter(ItemListModelAdapter())
        // HiveAdapter for ItemGroupModel
        ..registerAdapter(ItemGroupModelAdapter())
        // HiveAdapter for ItemBundleModel
        ..registerAdapter(ItemBundleModelAdapter());
    });
  }
}

import 'package:get/get.dart';

import '../../../components/global-widgets/my_snackbar.dart';
import '../../../data/local/hive/my_hive.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../service/REST/api_urls.dart';
import '../../../service/REST/dio_client.dart';
import '../../../service/handler/exception_handler.dart';
import '../../../service/helper/network_connectivity.dart';
import '../models/appointment_status_setting.dart';
import '../models/ticket_status_model.dart';

class SettingsController extends GetxController with ExceptionHandler {
  /// API ///
  final tickets = RxList<TicketStatusSettings>();
  getTicketStatus() async {
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(
        url: ApiUrl.getTicketStatusList,
        params: {
          "CompanyId": companyID,
        },
      ).catchError(handleError);

      if (response == null) return;

      tickets.assignAll((response as List)
          .map((e) => TicketStatusSettings.fromJson(e))
          .toList());
      await MyHive.saveAllTicketStatusSetting(tickets);
      hideLoading();
    } else {
      var savedTickets = MyHive.getAllTicketStatusSetting();
      if (savedTickets.isNotEmpty) {
        tickets.assignAll(savedTickets);

        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;

        showErrorDialog("Oops!", "Connection problem");

        return;
      }
    }
  }

  final appointmentsStatus = RxList<AppointmentStatusSetting>();
  getAppointmentStatus() async {
    if (await NetworkConnectivity.isNetworkAvailable()) {
      var companyID = await MySharedPref.getCompanyID();

      var response = await DioClient().get(
        url: ApiUrl.getAppointmentStatusList,
        params: {
          "CompanyId": companyID,
        },
      ).catchError(handleError);

      if (response == null) return;

      appointmentsStatus.assignAll((response as List)
          .map((e) => AppointmentStatusSetting.fromJson(e))
          .toList());
      await MyHive.saveAllAppointmentStatusSetting(appointmentsStatus);
    } else {
      var savedAppointments = MyHive.getAllAppointmentStatusSetting();
      if (savedAppointments.isNotEmpty) {
        appointmentsStatus.assignAll(savedAppointments);

        MySnackBar.showErrorToast(message: "No network!");
        NetworkConnectivity.connectionChangeCount = 1;
        return;
      } else {
        isError.value = true;
        NetworkConnectivity.connectionChangeCount = 1;

        showErrorDialog("Oops!", "Connection problem");

        return;
      }
    }
  }
}

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../components/global-widgets/my_snackbar.dart';
import '../../modules/appointment/controllers/appointment_controller.dart';
import '../../modules/customer/controllers/customer_controller.dart';
import '../../modules/invoice/controllers/invoice_controller.dart';

final appointmentController = Get.put(AppointmentController());
final customerController = Get.put(CustomerController());
final invoiceController = Get.put(InvoiceController());

class NetworkConnectivity {
  static StreamController<bool> connectivityController =
      StreamController<bool>.broadcast();

  static bool _isListenerInitialized = false;
  static int connectionChangeCount = 0;
  static bool _wasConnected = false;

  static Future<bool> isNetworkAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    bool isConnected = (connectivityResult.first != ConnectivityResult.none);

    connectivityController.add(isConnected);

    return isConnected;
  }

  static void initConnectivityListener() {
    if (!_isListenerInitialized) {
      _isListenerInitialized = true;
      Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) {
        // Assuming only one result is relevant for you, take the first result from the list.
        bool isConnected =
            result.isNotEmpty && (result.first != ConnectivityResult.none);
        connectivityController.add(isConnected);

        if (_wasConnected && !isConnected) {
          // Disconnected after being connected
          connectionChangeCount++;
          if (connectionChangeCount > 1) {
            // First or later disconnection
            _runDisconnectedOperations();
          }
        } else if (!_wasConnected && isConnected) {
          // Connected after being disconnected
          connectionChangeCount++;
          if (connectionChangeCount > 1) {
            // First or later reconnection
            _runConnectedOperations();
          }
        }
        _wasConnected = isConnected;
      });
    }
  }

  static void _runConnectedOperations() async {
    if (Get.isRegistered<AppointmentController>()) {
      await appointmentController.getAppointments();
    } else if (Get.isRegistered<CustomerController>()) {
      await customerController.getCustomers();
    }

    await 2.delay();
    MySnackBar.showSnackBar(
        title: "Connection restored!", message: 'Data loaded from network');
  }

  static void _runDisconnectedOperations() async {
    await 2.delay();
    MySnackBar.showErrorSnackBar(
        title: "Connection lost!", message: 'Data loaded from memory');
  }
}

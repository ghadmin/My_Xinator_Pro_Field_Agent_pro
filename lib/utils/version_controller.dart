import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionController extends GetxController {
  final RxString appVersion = ''.obs;
  final RxString buildNumber = ''.obs;
  final RxString appName = ''.obs;
  final RxString packageName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getAppInfo();
  }

  Future<void> getAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      appName.value = packageInfo.appName;
      packageName.value = packageInfo.packageName;
      appVersion.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;

      // // Print the version
      // print('App Name: ${appName.value}');
      // print('App Version: ${appVersion.value}');
      // print('Build Number: ${buildNumber.value}');
    } catch (e) {
      kLog('Error getting app info: $e');
    }
  }
}

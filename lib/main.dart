import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/utils/version_controller.dart';
import 'app/data/local/hive/hive_adapters.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/service/helper/network_connectivity.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(VersionController());
  // Device orientation
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  // init hive and adapters
  await HiveAdapters.registerAll();

  // Device info
  //  DeviceInfoHelper.initializeDeviceInfo();

  // Shared pref
  await MySharedPref.init();
  // Initialize GetX

  // Initialize background worker

  // inti fcm services
  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );

  // initialize local notifications
  // await NotificationHelper().initNotification();

  // Connectivity
  Future.delayed(Duration.zero, () {
    NetworkConnectivity.initConnectivityListener();
  });

  ///****************************************** My App ************************************///

  runApp(
    const MyApp(),
  );
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'com.pravera.flutter_foreground_task',
      channelName: 'Foreground Task',
      channelDescription: 'This is a foreground task',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000)),
  );
}

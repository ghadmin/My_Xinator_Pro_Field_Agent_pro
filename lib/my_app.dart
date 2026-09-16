import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';
import 'utils/responsive.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Phones keep the historical 360x690 design size (rendering unchanged).
      // Tablets use a square designSize set to the device's shortest logical
      // side, which makes the ScreenUtil scale ~1.0 in BOTH orientations —
      // text and .sp paddings render at their literal design values instead
      // of inflating ~2x.
      designSize: AppDevice.isTabletDevice
          ? Size(AppDevice.shortestLogicalSide,
              AppDevice.shortestLogicalSide)
          : ScreenUtil.defaultSize,
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        bool themeIsLight = MySharedPref.getThemeIsLight();
        return GetMaterialApp(
          title: "XinatorBMS Field Agent Pro",
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          theme: MyTheme.getThemeData(isLight: themeIsLight),
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
          initialRoute: Routes.SPLASH,
          defaultTransition: Transition.native,
          getPages: AppPages.routes,
          locale: MySharedPref.getCurrentLocal(),
          translations: LocalizationService.getInstance(),
        );
      },
    );
  }
}

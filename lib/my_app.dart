import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';

class MyApp extends GetView {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        return GetMaterialApp(
          title: "XinatorBMS FieldAgent",
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,

          builder: (context, widget) {
            bool themeIsLight = MySharedPref.getThemeIsLight();
            return Theme(
              data: MyTheme.getThemeData(isLight: themeIsLight),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              ),
            );
          },

          initialRoute: Routes.SPLASH,
          // first screen to show when app is running

          defaultTransition: Transition.native,

          getPages: AppPages.routes,
          // app screens
          locale: MySharedPref.getCurrentLocal(),
          // app language
          translations: LocalizationService
              .getInstance(), // localization services in app (controller app language)
        );
      },
    );
  }
}

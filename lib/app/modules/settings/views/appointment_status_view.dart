import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../components/global-widgets/splash_container.dart';
import '../controllers/settings_controller.dart';

class AppointmentStatusView extends GetView<SettingsController> {
  const AppointmentStatusView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Status'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.sp),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return SplashContainer(
            radius: 8,
            color: Colors.white,
            onPressed: () {},
            child: ListTile(
              title: Text(
                controller.appointmentsStatus[index].statusName ?? "",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              trailing: Icon(
                Remix.more_fill,
                size: 25.sp,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(
          height: 15.sp,
        ),
        itemCount: controller.appointmentsStatus.length,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/constants.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/global-widgets/asset_image_box.dart';
import '../../../components/global-widgets/text_widget.dart';
import '../../../routes/app_pages.dart';
import 'create_appointment_tutorial.dart';

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  static const List<_TrainingTopic> _topics = [
    _TrainingTopic(
      title: 'Create Appointment',
      icon: Icons.event_available_outlined,
    ),
    _TrainingTopic(
      title: 'Create Invoice',
      icon: Icons.receipt_long_outlined,
    ),
    _TrainingTopic(
      title: 'Update Invoice',
      icon: Icons.edit_note_outlined,
    ),
    _TrainingTopic(
      title: 'Payment',
      icon: Icons.payments_outlined,
    ),
    _TrainingTopic(
      title: 'Send SMS',
      icon: Icons.sms_outlined,
    ),
    _TrainingTopic(
      title: 'Forms',
      icon: Icons.description_outlined,
    ),
    _TrainingTopic(
      title: 'Pictures',
      icon: Icons.photo_camera_outlined,
    ),
    _TrainingTopic(
      title: 'Equipment',
      icon: Icons.handyman_outlined,
    ),
    _TrainingTopic(
      title: 'Files',
      icon: Icons.folder_outlined,
    ),
    _TrainingTopic(
      title: 'Notes',
      icon: Icons.sticky_note_2_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LightThemeColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const TextWidget(text: 'Training'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.sp),
            child: SizedBox(
              width: 35.sp,
              height: 35.sp,
              child: CircleAvatar(
                child: ClipOval(
                  child: AssetImageBox(
                    height: 35.sp,
                    width: 35.sp,
                    assetImage: AppImages.kDemoUser,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(indexClicked: 4),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: Column(
          children: [
            for (var i = 0; i < _topics.length; i++) ...[
              _topicCard(context, theme, i),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _topicCard(
    BuildContext context,
    ThemeData theme,
    int index,
  ) {
    final topic = _topics[index];
    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
        leading: Container(
          height: 40.sp,
          width: 40.sp,
          decoration: BoxDecoration(
            color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            topic.icon,
            size: 22.sp,
            color: LightThemeColors.primaryColor,
          ),
        ),
        title: TextWidget(
          text: topic.title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: LightThemeColors.bodyTextColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 22.sp,
          color: LightThemeColors.bodyTextSecondaryColor,
        ),
        onTap: () {
          if (index == 0) {
            _startCreateAppointmentTraining(context);
            return;
          }
          Get.snackbar(
            'Training',
            '${topic.title} training is coming soon.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }

  /// Opens the real Create Appointment page and, once it has settled in,
  /// plays the guided walkthrough over it with static content.
  void _startCreateAppointmentTraining(BuildContext context) {
    Get.toNamed(Routes.CREATE_APPOINTMENT);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!context.mounted) return;
      if (Get.currentRoute == Routes.CREATE_APPOINTMENT) {
        // Search from this page's context (below the root overlay);
        // rootOverlay renders the tour above the pushed page.
        CreateAppointmentTutorial.show(context);
      }
    });
  }
}

class _TrainingTopic {
  const _TrainingTopic({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

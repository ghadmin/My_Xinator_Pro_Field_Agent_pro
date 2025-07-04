import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/url_launcher.dart';
import '../../../components/global-widgets/main_divider.dart';
import '../controllers/customer_controller.dart';

class CustomerDetailsView extends GetView<CustomerController> {
  const CustomerDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Business Name",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.businessName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Title",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              controller.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Address",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: Text(
                                controller.address,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Mobile",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                await UrlLauncher.phoneCall(
                                    controller.mobileNumber);
                              },
                              child: Text(
                                controller.mobileNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Phone",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                await UrlLauncher.phoneCall(
                                    controller.phoneNumber);
                              },
                              child: Text(
                                controller.phoneNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Email",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: InkWell(
                                onTap: () async {
                                  await UrlLauncher.email(controller.email);
                                },
                                child: Text(
                                  controller.email,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Invoices",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: InkWell(
                                onTap: () {},
                                child: Text(
                                  "See Invoices >",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Estimates",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: InkWell(
                                onTap: () {},
                                child: Text(
                                  "See Estimates >",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Appointments",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {},
                              child: Text(
                                "See Appointments >",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Files",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: InkWell(
                                onTap: () {},
                                child: Text(
                                  'View Files >',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: Text(
                              "Email History",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {},
                              child: Text(
                                'See History >',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

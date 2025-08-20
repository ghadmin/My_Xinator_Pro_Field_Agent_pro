// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:xinator_fsm_pro/app/modules/customer/models/customer_model.dart';

// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../../utils/url_launcher.dart';
// import '../../../components/global-widgets/main_divider.dart';
// import '../controllers/customer_controller.dart';

// class CustomerDetailsView extends StatefulWidget {
//   const CustomerDetailsView({super.key});

//   @override
//   State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
// }

// class _CustomerDetailsViewState extends State<CustomerDetailsView>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   final controller = Get.find<CustomerController>();

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 6, vsync: this);
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const  TextWidget(text:'Customer Details'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TabBar(
//               isScrollable: true,
//               controller: tabController,
//               labelColor: Colors.blue, // Selected tab text color
//               unselectedLabelColor: Colors.black, // Unselected tab text color
//               indicatorColor: Colors.blue, // Underline color for selected tab
//               tabs: const [
//                 Tab(text: "Basic Details"),
//                 Tab(text: "Appointments"),
//                 Tab(text: "Invoice & Estimates"),
//                 Tab(text: "Equipment"),
//                 Tab(text: "Maintenance Agreement"),
//                 Tab(text: "Pictures"),
//               ],
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     BasicDetailsWidget(
//                         theme: theme,
//                         customer: controller.selectedCustomer.value!),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BasicDetailsWidget extends StatelessWidget {
//   const BasicDetailsWidget(
//       {super.key, required this.theme, required this.customer});

//   final ThemeData theme;
//   final CustomerModel customer;

//   @override
//   Widget build(BuildContext context) {
//     final fullName = (customer.firstName?.isNotEmpty == true &&
//             customer.lastName?.isNotEmpty == true)
//         ? '${customer.firstName} ${customer.lastName}'
//         : (customer.firstName?.isNotEmpty == true)
//             ? customer.firstName!
//             : (customer.lastName?.isNotEmpty == true)
//                 ? customer.lastName!
//                 : 'N/A';

//     return Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16), // <-- set your radius here
//         ),
//         color: Colors.white,
//         child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                    TextWidget(text:
//                     fullName,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: LightThemeColors.appBlackColor,
//                       fontSize: 27.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.email_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Email",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.email ?? "N/A",
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.end,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Address",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.address1 ?? "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.call,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Phone",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.phone ?? "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             Image.asset(
//                               'assets/images/customers/status_icon.png',
//                               width: 20,
//                               height: 20,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Status",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             "Scheduled",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               color: Colors.green,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_month_outlined,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                              TextWidget(text:
//                               "Created On",
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: LightThemeColors.hintTextColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: SizedBox(
//                           child:  TextWidget(text:
//                             customer.createdDateTime != null
//                                 ? customer.createdDateTime.runtimeType == String
//                                     ? DateFormat("M/d/yyyy h:mm:ss a")
//                                         .parse(customer.createdDateTime!)
//                                         .toLocal()
//                                         .toString()
//                                     : customer.createdDateTime!
//                                         .toLocal()
//                                         .toString()
//                                 : "N/A",
//                             textAlign: TextAlign.end,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 14.sp,
//                               color: LightThemeColors.hintTextColor,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   // Row(
//                   //   children: [
//                   //     Expanded(
//                   //       flex: 2,
//                   //       child: Row(
//                   //         children: [
//                   //           Image.asset(
//                   //             'assets/images/customers/instrunction.png',
//                   //             width: 20,
//                   //             height: 20,
//                   //             color: Colors.grey,
//                   //           ),
//                   //           SizedBox(
//                   //             width: 5,
//                   //           ),
//                   //            TextWidget(text:
//                   //             "Special Instruction",
//                   //             style: theme.textTheme.bodyLarge?.copyWith(
//                   //               color: LightThemeColors.hintTextColor,
//                   //               fontSize: 14.sp,
//                   //               overflow: TextOverflow.ellipsis,
//                   //               fontWeight: FontWeight.w500,
//                   //             ),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //     Expanded(
//                   //       flex: 3,
//                   //       child: SizedBox(
//                   //         child:  TextWidget(text:
//                   //           customer.jobTitle ?? "N/A",
//                   //           textAlign: TextAlign.end,
//                   //           style: theme.textTheme.bodyLarge?.copyWith(
//                   //             fontSize: 14.sp,
//                   //             color: LightThemeColors.hintTextColor,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     )
//                   //   ],
//                   // ),
//                   // SizedBox(
//                   //   height: 10.h,
//                   // ),
//                 ])));
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart'
    show TextWidget;

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
        toolbarHeight:
            Platform.isAndroid ? kToolbarHeight : kToolbarHeight + 60,
        title: const TextWidget(text: 'Customer Details'),
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
                            title: TextWidget(
                              text: "Business Name",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: TextWidget(
                              text: controller.businessName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: TextWidget(
                              text: "Title",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: TextWidget(
                              text: controller.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: TextWidget(
                              text: "Address",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200.sp,
                              child: TextWidget(
                                text: controller.address,
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
                            title: TextWidget(
                              text: "Mobile",
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
                              child: TextWidget(
                                text: controller.mobileNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: TextWidget(
                              text: "Phone",
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
                              child: TextWidget(
                                text: controller.phoneNumber,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          MainDivider(),
                          ListTile(
                            title: TextWidget(
                              text: "Email",
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
                                child: TextWidget(
                                  text: controller.email,
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
                            title: TextWidget(
                              text: "Invoices",
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
                                child: TextWidget(
                                  text: "See Invoices >",
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
                            title: TextWidget(
                              text: "Estimates",
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
                                child: TextWidget(
                                  text: "See Estimates >",
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
                            title: TextWidget(
                              text: "Appointments",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {},
                              child: TextWidget(
                                text: "See Appointments >",
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
                            title: TextWidget(
                              text: "Files",
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
                                child: TextWidget(
                                  text: 'View Files >',
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
                            title: TextWidget(
                              text: "Email History",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: LightThemeColors.hintTextColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {},
                              child: TextWidget(
                                text: 'See History >',
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

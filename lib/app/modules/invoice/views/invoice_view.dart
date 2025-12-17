// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../../../config/theme/light_theme_colors.dart';
// import '../../../../utils/constants.dart';
// import '../../../../utils/date_converter.dart';
// import '../../../components/global-widgets/asset_image_box.dart';
// import '../../../components/global-widgets/empty_widget.dart';
// import '../../../components/global-widgets/splash_container.dart';
// import '../../../routes/app_pages.dart';
// import '../controllers/invoice_controller.dart';
//
// class InvoiceView extends GetView<InvoiceController> {
//   const InvoiceView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Invoices'),
//         centerTitle: true,
//         actions: [
//           InkWell(
//             onTap: () {},
//             child: Padding(
//               padding: EdgeInsets.only(right: 18.sp),
//               child: SizedBox(
//                 width: 35.sp, // Specify the width and height you want
//                 height: 35.sp,
//                 child: CircleAvatar(
//                   child: ClipOval(
//                     child: AssetImageBox(
//                       height: 35.sp,
//                       width: 35.sp,
//                       assetImage: AppImages.kDemoUser,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Obx(() => Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
//             child: controller.isInvoiceEmpty.value
//                 ? EmptyWidget(
//                     onPressed: () async {
//                       await controller.getInvoices();
//                     },
//                   )
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Invoice/Estimate List",
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Text(
//                         "Create invoices/estimates easily",
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: LightThemeColors.hintTextColor,
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       SizedBox(height: 20.sp),
//                       // SplashContainer(
//                       //     width: 80.sp,
//                       //     color: Colors.white,
//                       //     radius: 5,
//                       //     onPressed: () {},
//                       //     child: Container(
//                       //       padding: EdgeInsets.symmetric(
//                       //         horizontal: 10.sp,
//                       //         vertical: 5.sp,
//                       //       ),
//                       //       decoration: BoxDecoration(
//                       //         border: Border.all(
//                       //           color: theme.primaryColor,
//                       //         ),
//                       //         borderRadius: BorderRadius.circular(5.r),
//                       //       ),
//                       //       child: Row(
//                       //         children: [
//                       //           Icon(
//                       //             Iconsax.filter,
//                       //             color: theme.primaryColor,
//                       //             size: 18.sp,
//                       //           ),
//                       //           SizedBox(width: 8.sp),
//                       //           Text(
//                       //             "Filter",
//                       //             style: theme.textTheme.bodyMedium?.copyWith(
//                       //               color: theme.primaryColor,
//                       //             ),
//                       //           ),
//                       //         ],
//                       //       ),
//                       //     )),
//                       // SizedBox(height: 20.sp),
//                       Expanded(
//                         child: RefreshIndicator(
//                           color: theme.primaryColor,
//                           onRefresh: () async => await controller.getInvoices(),
//                           child: ListView.separated(
//                             padding: EdgeInsets.zero,
//                             physics: BouncingScrollPhysics(),
//                             itemCount: controller.invoices.length,
//                             itemBuilder: (context, index) {
//                               final invoice = controller.invoices[index];
//                               return SplashContainer(
//                                 radius: 8,
//                                 color: Colors.white,
//                                 onPressed: () {
//                                   var dateTime = dateTimeConverter(
//                                       inputFormat: "yyyy/MM/dd",
//                                       inputTime: invoice.invoiceDate.toString(),
//                                       outputFormat: "MM/dd/yyyy");
//                                   controller.invoiceNumber =
//                                       invoice.number ?? "";
//                                   controller.customerName =
//                                       invoice.fullName ?? "";
//                                   controller.address =
//                                       "${invoice.invoice?.city}";
//                                   controller.selectedInvoiceIndex.value = index;
//                                   controller.surcharges =
//                                       "${invoice.invoice?.surcharge ?? ""}";
//                                   controller.date = dateTime;
//                                   controller.subtotal = invoice
//                                           .invoice?.subtotal
//                                           ?.toStringAsFixed(1) ??
//                                       "";
//                                   controller.discount =
//                                       invoice.invoice?.discount?.toString() ??
//                                           "";
//                                   controller.status = invoice.status ?? "";
//                                   controller.tax =
//                                       invoice.invoice?.tax.toString() ?? "";
//                                   controller.type = invoice.type ?? "";
//                                   controller.total.value = invoice
//                                           .invoice?.total
//                                           ?.toStringAsFixed(1) ??
//                                       "";
//                                   controller.newTotal.value =
//                                       controller.total.value;
//                                   controller.paid = invoice
//                                           .invoice?.depositAmount
//                                           ?.toStringAsFixed(1) ??
//                                       "";
//                                   controller.notes =
//                                       invoice.invoice?.note ?? "";
//                                   controller.due = invoice.invoice?.due
//                                           ?.toStringAsFixed(1) ??
//                                       "";
//                                   Get.toNamed(Routes.INVOICE_DETAILS);
//                                 },
//                                 child: Padding(
//                                   padding: EdgeInsets.all(15.sp),
//                                   child: IntrinsicHeight(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               invoice.number ?? "",
//                                               style: theme.textTheme.bodySmall
//                                                   ?.copyWith(
//                                                       color: LightThemeColors
//                                                           .hintTextColor),
//                                             ),
//                                             Text(
//                                               invoice.fullName ?? "",
//                                               style: theme.textTheme.bodyLarge
//                                                   ?.copyWith(
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                             SizedBox(height: 2.sp),
//                                             Text(
//                                               invoice.type ?? "",
//                                               style: theme.textTheme.bodySmall
//                                                   ?.copyWith(
//                                                       color: LightThemeColors
//                                                           .hintTextColor),
//                                             ),
//                                             SizedBox(height: 2.sp),
//                                             Text(
//                                               dateTimeConverter(
//                                                   inputFormat: "yyyy/MM/dd",
//                                                   inputTime: invoice.invoiceDate
//                                                       .toString(),
//                                                   outputFormat: "MM/dd/yyyy"),
//                                               style: theme.textTheme.bodySmall
//                                                   ?.copyWith(
//                                                       color: LightThemeColors
//                                                           .hintTextColor),
//                                             ),
//                                             SizedBox(height: 10.sp),
//                                             Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 10.sp,
//                                                   vertical: 2.sp),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.r),
//                                                 color: invoice.status == "Due"
//                                                     ? Color(0xffE98862)
//                                                     : invoice.status == "Unpaid"
//                                                         ? Colors.red
//                                                         : Color(0xff0CBC8B),
//                                               ),
//                                               child: Text(
//                                                 invoice.status ?? "",
//                                                 style: theme
//                                                     .textTheme.bodyMedium
//                                                     ?.copyWith(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           children: [
//                                             Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 10.sp,
//                                                   vertical: 5.sp),
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.end,
//                                                 children: [
//                                                   Text(
//                                                     "Total",
//                                                     style: theme
//                                                         .textTheme.bodySmall
//                                                         ?.copyWith(
//                                                             color: LightThemeColors
//                                                                 .hintTextColor),
//                                                   ),
//                                                   Text(
//                                                     "\$${invoice.total?.toStringAsFixed(1) ?? ""}",
//                                                     style: theme
//                                                         .textTheme.headlineSmall
//                                                         ?.copyWith(
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Text(
//                                               "Click to see details",
//                                               style: theme.textTheme.bodySmall
//                                                   ?.copyWith(
//                                                 color: theme.primaryColor,
//                                                 fontSize: 11.sp,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                             separatorBuilder: (context, index) =>
//                                 SizedBox(height: 15.sp),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           )),
//     );
//   }
// }

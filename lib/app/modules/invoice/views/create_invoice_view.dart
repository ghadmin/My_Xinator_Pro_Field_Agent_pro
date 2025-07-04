import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/asset_image_box.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/general_text_field.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/my_buttons.dart';
import 'package:xinator_fsm_pro/app/modules/invoice/controllers/invoice_controller.dart';
import 'package:xinator_fsm_pro/utils/constants.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../utils/date_converter.dart';
import '../../../../utils/url_launcher.dart';
import '../../../components/global-widgets/splash_container.dart';

class CreateInvoiceView extends GetView<InvoiceController> {
  const CreateInvoiceView({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${controller.selectedCreateType.value}'),
        actions: [
          Obx(() {
            return controller.isInvoiceSaved.value
                ? Padding(
                    padding: EdgeInsets.only(right: 15.sp),
                    child: IconButton(
                      onPressed: () async {
                        await controller.getEmailAutofill(
                            emailType: controller.selectedCreateType.value);
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            enableDrag: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20.sp,
                                      right: 20.sp,
                                      bottom: 20.sp,
                                      top: 5.sp),
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Send Email",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w500,
                                            )),
                                        SizedBox(height: 15.sp),
                                        GeneralTextField(
                                          hint: "To",
                                          theme: theme,
                                          textInputType:
                                              TextInputType.emailAddress,
                                          textEditingController:
                                              controller.toTextController,
                                        ),
                                        SizedBox(height: 10.sp),
                                        GeneralTextField(
                                          hint: "Bcc",
                                          theme: theme,
                                          textInputType:
                                              TextInputType.emailAddress,
                                          textEditingController:
                                              controller.bccTextController,
                                        ),
                                        SizedBox(height: 10.sp),
                                        GeneralTextField(
                                          hint: "Subject",
                                          maxLine: 3,
                                          theme: theme,
                                          textEditingController:
                                              controller.subjectTextController,
                                        ),
                                        SizedBox(height: 10.sp),
                                        GeneralTextField(
                                          hint: "Email body",
                                          theme: theme,
                                          maxLine: 6,
                                          textEditingController: controller
                                              .emailBodyTextController,
                                        ),
                                        SizedBox(height: 10.sp),
                                        // Obx(() => SizedBox(
                                        //       height: controller
                                        //                   .selectedFiles.length <
                                        //               5
                                        //           ? controller
                                        //                   .selectedFiles.length *
                                        //               50.sp
                                        //           : 200.sp,
                                        //       child: ListView.builder(
                                        //         shrinkWrap: true,
                                        //         physics: controller.selectedFiles
                                        //                     .length <
                                        //                 4
                                        //             ? NeverScrollableScrollPhysics()
                                        //             : BouncingScrollPhysics(),
                                        //         itemCount: controller
                                        //             .selectedFiles.length,
                                        //         itemBuilder: (context, index) {
                                        //           return ListTile(
                                        //             leading: Icon(
                                        //               Remix.file_2_line,
                                        //               color: Colors.green,
                                        //               size: 16.sp,
                                        //             ),
                                        //             title: Text(controller
                                        //                 .selectedFiles[index].path
                                        //                 .split('/')
                                        //                 .last),
                                        //             trailing: IconButton(
                                        //               icon: Icon(
                                        //                 Icons.remove_circle,
                                        //                 color:
                                        //                     Colors.red.shade300,
                                        //               ),
                                        //               onPressed: () {
                                        //                 controller.selectedFiles
                                        //                     .removeAt(index);
                                        //                 controller.docFileList =
                                        //                     RxList.from(controller
                                        //                         .selectedFiles); // Update docFileList for upload
                                        //               },
                                        //             ),
                                        //           );
                                        //         },
                                        //       ),
                                        //     )),
                                        // SizedBox(
                                        //   height: 48.sp,
                                        //   child: SecondaryButtonWithIcon(
                                        //       title: "Add Attachment",
                                        //       onPressed: () async {
                                        //         await controller.pickFiles();
                                        //       },
                                        //       iconData: Remix.attachment_line,
                                        //       inactive: false),
                                        // ),
                                        SizedBox(height: 10.sp),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 48.sp,
                                                child: SecondaryButton(
                                                  title: "Cancel",
                                                  onPressed: () {
                                                    controller.toTextController
                                                        .clear();
                                                    controller.bccTextController
                                                        .clear();
                                                    controller
                                                        .subjectTextController
                                                        .clear();
                                                    controller
                                                        .emailBodyTextController
                                                        .clear();
                                                    controller.selectedFiles
                                                        .clear();
                                                    Get.back();
                                                  },
                                                  inactive: false,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.sp),
                                            Expanded(
                                              child: SizedBox(
                                                height: 48.sp,
                                                child: PrimaryButton(
                                                    title: "Send",
                                                    onPressed: () async {
                                                      await controller.sendEmail(
                                                          pdfType: controller
                                                              .selectedCreateType
                                                              .value,
                                                          emailType: controller
                                                              .selectedCreateType
                                                              .value);
                                                    },
                                                    inactive: false),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 50.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      icon: Icon(
                        Remix.telegram_2_fill,
                        color: theme.primaryColor,
                      ),
                    ),
                  )
                : SizedBox.shrink();
          }),
        ],
        centerTitle: false,
      ),
      body: Obx(() => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SplashContainer(
                      radius: 8,
                      color: Colors.white,
                      onPressed: () {},
                      child: Padding(
                        padding: EdgeInsets.all(20.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "INFO",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: LightThemeColors.hintTextColor,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  controller.invoiceName.value,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: LightThemeColors.hintTextColor,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  dateTimeConverter(
                                      inputTime: DateTime.now().toString(),
                                      outputFormat: "MM/dd/yyyy"),
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    SplashContainer(
                      radius: 8,
                      color: Colors.white,
                      onPressed: () {},
                      child: Padding(
                        padding: EdgeInsets.all(20.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 220.sp,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "To",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: LightThemeColors.hintTextColor,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    controller.createCustomerName,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 3.sp),
                                  Text(
                                    controller.createCustomerAddress,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(fontSize: 12.sp),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  controller.createCustomerPhone.isEmpty
                                      ? SizedBox.shrink()
                                      : InkWell(
                                          onTap: () async {
                                            await UrlLauncher.phoneCall(
                                                controller.createCustomerPhone);
                                          },
                                          child: Text(
                                            controller.createCustomerPhone,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 12.sp),
                                          ),
                                        ),
                                  controller.createCustomerEmail.isEmpty
                                      ? SizedBox.shrink()
                                      : InkWell(
                                          onTap: () async {
                                            await UrlLauncher.email(
                                                controller.createCustomerEmail);
                                          },
                                          child: Text(
                                            controller.createCustomerEmail,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: LightThemeColors
                                                        .hintTextColor,
                                                    fontSize: 12.sp),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            AssetImageBox(
                                height: 60.sp,
                                width: 60.sp,
                                assetImage: AppImages.kAppIcon),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    controller.selectedItemList.isEmpty
                        ? SizedBox.shrink()
                        : Card(
                            elevation: 0,
                            color: Colors.white,
                            child: ListView.separated(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.sp, vertical: 10.sp),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return SplashContainer(
                                    radius: 8,
                                    onPressed: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: .5.sp,
                                            color: theme.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(8.sp),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20.sp),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: .4.sw,
                                                  child: Text(
                                                    controller
                                                            .selectedItemList[
                                                                index]
                                                            .name ??
                                                        "",
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                  ),
                                                ),
                                                SizedBox(height: 2.sp),
                                                controller
                                                        .descriptionControllers[
                                                            index]
                                                        .text
                                                        .isEmpty
                                                    ? SizedBox.shrink()
                                                    : SizedBox(
                                                        width: .4.sw,
                                                        child: Text(
                                                          controller
                                                              .descriptionControllers[
                                                                  index]
                                                              .text,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: LightThemeColors
                                                                .bodyTextSecondaryColor,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                SizedBox(height: 10.sp),
                                                Text(
                                                    "${controller.quantityControllers[index].text} X \$${controller.amountControllers[index].text}"),
                                                SizedBox(height: 4.sp),
                                                Text(
                                                  "Taxable: ${controller.selectedItemList[index].isTaxable == true ? "Yes" : "No"}",
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      showAdaptiveDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'Delete Item',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              content: const Text(
                                                                  'Are you sure you want to delete the item?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.back();
                                                                  },
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.back();
                                                                    controller
                                                                        .removeItem(
                                                                            index);
                                                                  },
                                                                  child: Text(
                                                                    'Delete',
                                                                    style:
                                                                        TextStyle(
                                                                      color: LightThemeColors
                                                                          .bodyTextSecondaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    icon: Icon(
                                                      Remix.delete_bin_2_line,
                                                      color: Colors.red,
                                                    )),
                                                SizedBox(width: 10.sp),
                                                IconButton(
                                                    onPressed: () {
                                                      showAdaptiveDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        builder: (context) {
                                                          return Dialog(
                                                            insetPadding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16.sp), // Add padding for smaller screens
                                                            child:
                                                                ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: 1
                                                                    .sw, // Enforce the calculated width
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .all(16
                                                                            .sp),
                                                                    child: Text(
                                                                      'Edit Item',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyLarge,
                                                                    ),
                                                                  ),

                                                                  // Content
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16.sp),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              "Description",
                                                                              style: theme.textTheme.bodyLarge,
                                                                            ),
                                                                            SizedBox(width: 10.sp),
                                                                            Expanded(
                                                                              child: GeneralTextField(
                                                                                hint: "Description",
                                                                                theme: theme,
                                                                                maxLine: 4,
                                                                                textEditingController: controller.descriptionControllers[index],
                                                                                onChanged: (v) {
                                                                                  controller.selectedItemList[index].description = v;
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10.sp),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              "Amount: \$",
                                                                              style: theme.textTheme.bodyLarge,
                                                                            ),
                                                                            SizedBox(width: 18.sp),
                                                                            Expanded(
                                                                              child: GeneralTextField(
                                                                                hint: "Amount",
                                                                                textInputType: TextInputType.numberWithOptions(decimal: true),
                                                                                theme: theme,
                                                                                textEditingController: controller.amountControllers[index],
                                                                                onChanged: (value) {
                                                                                  controller.createTotal(); // Recalculate total when amount changes
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10.sp),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              "Quantity:",
                                                                              style: theme.textTheme.bodyLarge,
                                                                            ),
                                                                            SizedBox(width: 25.sp),
                                                                            Expanded(
                                                                              child: GeneralTextField(
                                                                                hint: '1',
                                                                                textInputType: TextInputType.number,
                                                                                theme: theme,
                                                                                textEditingController: controller.quantityControllers[index],
                                                                                onChanged: (value) {
                                                                                  controller.createTotal();
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                      height: 15
                                                                          .sp),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .all(16
                                                                            .sp),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          45.sp,
                                                                      width:
                                                                          .4.sw,
                                                                      child: PrimaryButton(
                                                                          title: "Close",
                                                                          onPressed: () {
                                                                            Get.back();
                                                                          },
                                                                          inactive: false),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon: Icon(
                                                        Remix.edit_2_line)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 8.sp);
                                },
                                itemCount: controller.selectedItemList.length),
                          ),
                    SizedBox(height: 8.sp),
                    Builder(builder: (context) {
                      return SizedBox(
                        height: 48.sp,
                        child: SecondaryButtonWithIcon(
                          title: "Add item",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Container(
                                    height: .6.sh,
                                    padding: EdgeInsets.all(20.sp),
                                    child: Column(
                                      children: [
                                        GeneralTextField(
                                            maxLine: 2,
                                            hint: "Search here...",
                                            theme: theme,
                                            onChanged: (_) => controller
                                                .itemController
                                                .sortItems(),
                                            textEditingController: controller
                                                .itemController
                                                .sortTextController),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Expanded(
                                          child: ListView(
                                            children: controller
                                                .itemController.sortedItems
                                                .map((item) {
                                              return ListTile(
                                                title: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.sp,
                                                      vertical: 10.sp),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.sp),
                                                    border: Border.all(
                                                      color: LightThemeColors
                                                          .bodyTextSecondaryColor,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name ?? "",
                                                        style: TextStyle(
                                                          color:
                                                              LightThemeColors
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.sp),
                                                      item.description == ""
                                                          ? SizedBox.shrink()
                                                          : Text(
                                                              item.description ??
                                                                  ""),
                                                      SizedBox(height: 8.sp),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Price: \$${item.price}",
                                                            style: TextStyle(
                                                              color: LightThemeColors
                                                                  .bodyTextSecondaryColor,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Taxable: ${item.isTaxable == true ? "Yes" : "No"}",
                                                            style: TextStyle(
                                                              color: LightThemeColors
                                                                  .bodyTextSecondaryColor,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (!controller
                                                      .selectedItemList
                                                      .contains(item)) {
                                                    controller.selectedItemList
                                                        .add(item);
                                                    controller.amountControllers
                                                        .add(TextEditingController(
                                                            text: item.price
                                                                .toString()));

                                                    controller
                                                        .descriptionControllers
                                                        .add(TextEditingController(
                                                            text:
                                                                item.description ??
                                                                    ""));
                                                    controller
                                                        .quantityControllers
                                                        .add(
                                                            TextEditingController(
                                                                text: '1'));
                                                  }
                                                  controller.createTotal();
                                                  Get.back();
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          iconData: Icons.add_circle_outline,
                          inactive: false,
                        ),
                      );
                    }),
                    SizedBox(height: 15.sp),
                    Obx(() => Column(
                          children: [
                            ListTile(
                              title: Text(
                                "Subtotal",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      LightThemeColors.bodyTextSecondaryColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                              trailing: Text(
                                "\$${controller.invoiceSubtotal.value.toStringAsFixed(2)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            // ListTile(
                            //   title: Text(
                            //     "Surcharge",
                            //     style: theme.textTheme.bodyMedium?.copyWith(
                            //       color: LightThemeColors.bodyTextSecondaryColor,
                            //       fontSize: 16.sp,
                            //     ),
                            //   ),
                            //   trailing: Text(
                            //     "3%",
                            //     style: theme.textTheme.bodyLarge,
                            //   ),
                            // ),
                            // ListTile(
                            //   title: Row(
                            //     children: [
                            //       Text(
                            //         "Surcharge",
                            //         style: theme.textTheme.bodyLarge?.copyWith(
                            //           color: LightThemeColors.hintTextColor,
                            //           fontSize: 14.sp,
                            //           fontWeight: FontWeight.w500,
                            //         ),
                            //       ),
                            //       SizedBox(width: 20.sp),
                            //       Transform.scale(
                            //         scale: 0.65,
                            //         child: SizedBox(
                            //           width: 35.sp,
                            //           child: CupertinoSwitch(
                            //             activeTrackColor: theme.primaryColor,
                            //             inactiveTrackColor: Colors.red,
                            //             value: controller.isApplyingSurcharge.value,
                            //             onChanged: (v) async {
                            //               controller.toggleBlockStatus(v);
                            //               controller.createTotal();
                            //             },
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            //   trailing: Text(
                            //     "\$${double.parse(controller.surcharges).toStringAsFixed(2)}",
                            //     style: theme.textTheme.bodyLarge?.copyWith(
                            //       fontSize: 14.sp,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            // ListTile(
                            //   title: Text(
                            //     "Deposit",
                            //     style: theme.textTheme.bodyMedium?.copyWith(
                            //       color: LightThemeColors.bodyTextSecondaryColor,
                            //       fontSize: 16.sp,
                            //     ),
                            //   ),
                            //   trailing: Text(
                            //     "\$0.00",
                            //     style: theme.textTheme.bodyLarge,
                            //   ),
                            // ),
                            ListTile(
                              title: Builder(builder: (context) {
                                return SplashContainer(
                                  color: Colors.white,
                                  radius: 8,
                                  onPressed: () {
                                    RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    Offset offset = renderBox
                                        .localToGlobal(Offset(0, 32.sp));
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject() as RenderBox;
                                    showMenu(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.r)),
                                      ),
                                      context: context,
                                      position: RelativeRect.fromRect(
                                          offset &
                                              Size(
                                                  32.sp,
                                                  32
                                                      .sp), // smaller rect, the touch area
                                          Offset.zero &
                                              overlay
                                                  .size // Bigger rect, the entire screen
                                          ),
                                      items:
                                          controller.discountOptions.map((e) {
                                        return PopupMenuItem(
                                          value: e["value"],
                                          child: Text(e["name"] ?? ""),
                                        );
                                      }).toList(),
                                    ).then((selectedValue) {
                                      if (selectedValue != null) {
                                        final selectedDiscount = controller
                                            .discountOptions
                                            .firstWhere((element) =>
                                                element["value"] ==
                                                selectedValue);
                                        controller.selectedDiscountOption
                                            .value = selectedDiscount["value"];
                                        controller.createTotal();
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.sp, vertical: 5.sp),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      border: Border.all(
                                          color: LightThemeColors.primaryColor,
                                          width: 1.sp),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Discount",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: LightThemeColors
                                                .bodyTextSecondaryColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(width: 5.sp),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: LightThemeColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              trailing: SizedBox(
                                width: 155.sp,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      controller.selectedDiscountOption.value ==
                                              "2"
                                          ? "\$"
                                          : "%",
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 5.sp),
                                    SizedBox(
                                      height: 35.sp,
                                      width: 100.sp,
                                      child: GeneralTextField(
                                        hint: "0.00",
                                        textInputType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        theme: theme,
                                        textAlignment: TextAlign.end,
                                        textEditingController: controller
                                            .createDiscountTextController,
                                        onChanged: (value) {
                                          controller.createTotal();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 18.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      controller.selectedDiscountOption.value ==
                                              "2"
                                          ? "Fixed"
                                          : "Percentage",
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: LightThemeColors
                                            .bodyTextSecondaryColor,
                                      )),
                                ],
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Discount amounts:",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "-\$${(controller.invoiceDiscount.value).toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.sp),
                            Divider(
                              height: 1.sp,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Amount after discount:",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "\$${((controller.invoiceSubtotal.value) - (controller.invoiceDiscount.value)).toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Total Price of Non-Taxable Items",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "- \$${controller.nonTaxableItemTotalInCreate.value.toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Taxable total",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "\$${((controller.invoiceSubtotal.value - controller.invoiceDiscount.value) - controller.nonTaxableItemTotalInCreate.value).toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListTile(
                              title: Builder(builder: (context) {
                                return SplashContainer(
                                  color: Colors.white,
                                  radius: 8,
                                  onPressed: () {
                                    RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    Offset offset = renderBox
                                        .localToGlobal(Offset(0, 32.sp));
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject() as RenderBox;
                                    showMenu(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.r)),
                                      ),
                                      context: context,
                                      position: RelativeRect.fromRect(
                                          offset &
                                              Size(
                                                  32.sp,
                                                  32
                                                      .sp), // smaller rect, the touch area
                                          Offset.zero &
                                              overlay
                                                  .size // Bigger rect, the entire screen
                                          ),
                                      items: [
                                        PopupMenuItem(
                                          value: "",
                                          child: Text(
                                            "NO TAX",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        ...controller.taxes.map((tax) {
                                          return PopupMenuItem(
                                            value: tax.id,
                                            child: Text(tax.name ?? ""),
                                          );
                                        }),
                                      ],
                                    ).then((selectedValue) async {
                                      if (selectedValue != null) {
                                        if (selectedValue == "") {
                                          controller.selectedTaxName.value =
                                              "NO TAX";
                                          controller.tax.value = "0.00";
                                          controller.selectedTaxID.value = "";
                                          controller.createTotal();
                                        } else {
                                          final selectedTax = controller.taxes
                                              .firstWhere((tax) =>
                                                  tax.id == selectedValue);
                                          controller.selectedTaxName.value =
                                              selectedTax.name ?? "";
                                          controller.tax.value = selectedTax
                                                  .rate
                                                  ?.toStringAsFixed(2) ??
                                              "0.00";
                                          controller.selectedTaxID.value =
                                              selectedTax.id.toString();
                                          controller.createTotal();
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.sp, vertical: 5.sp),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      border: Border.all(
                                          color: LightThemeColors.primaryColor,
                                          width: 1.sp),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Tax Rate",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: LightThemeColors
                                                  .hintTextColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            )),
                                        SizedBox(width: 5.sp),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: LightThemeColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              trailing: SizedBox(
                                width: 165.sp,
                                child: Text(
                                  "\$${((controller.invoiceSubtotal.value - controller.invoiceDiscount.value) - controller.nonTaxableItemTotalInCreate.value).toStringAsFixed(2)} x ${double.parse(controller.tax.value).toStringAsFixed(2)}%",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                            controller.selectedTaxName.value == ""
                                ? Padding(
                                    padding: EdgeInsets.only(left: 18.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("NO TAX (0.00%)",
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: LightThemeColors
                                                  .bodyTextSecondaryColor,
                                            )),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(left: 18.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${controller.selectedTaxName.value} (${controller.tax.value}%)",
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: LightThemeColors
                                                  .bodyTextSecondaryColor,
                                            )),
                                      ],
                                    ),
                                  ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Tax amount:",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "+\$${(((controller.invoiceSubtotal.value - controller.invoiceDiscount.value) - controller.nonTaxableItemTotalInCreate.value) * (double.tryParse(controller.tax.value) ?? 0) / 100).toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.sp),
                            Divider(
                              height: 1.sp,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Amount after adding Tax:",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 10.sp,
                                      color: LightThemeColors
                                          .bodyTextSecondaryColor),
                                ),
                                SizedBox(width: 20.sp),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: Text(
                                    "\$${(((controller.invoiceSubtotal.value - controller.invoiceDiscount.value) - controller.nonTaxableItemTotalInCreate.value) * (double.tryParse(controller.tax.value) ?? 0) / 100 + ((controller.invoiceSubtotal.value) - (controller.invoiceDiscount.value))).toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.sp),
                            Divider(
                              height: 1.sp,
                              color: theme.primaryColor,
                            ),
                            ListTile(
                              title: Text(
                                "Total",
                                style: theme.textTheme.bodyLarge,
                              ),
                              trailing: Text(
                                "\$${(((controller.invoiceSubtotal.value - controller.invoiceDiscount.value) - controller.nonTaxableItemTotalInCreate.value) * (double.tryParse(controller.tax.value) ?? 0) / 100 + ((controller.invoiceSubtotal.value) - (controller.invoiceDiscount.value))).toStringAsFixed(2)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 15.sp),
                    GeneralTextField(
                        hint: "Add a note",
                        theme: theme,
                        maxLine: 4,
                        textEditingController: controller.noteTextController),
                    SizedBox(height: 20.sp),
                    SizedBox(
                      height: 48.sp,
                      width: double.infinity,
                      child: PrimaryButton(
                        title: "Save",
                        onPressed: () async {
                          await controller.createInvoice();
                        },
                        inactive: controller.selectedItemList.isEmpty,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

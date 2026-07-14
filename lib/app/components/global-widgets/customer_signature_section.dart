import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../modules/invoice/controllers/invoice_controller.dart';
import '../../modules/invoice/views/customer_signature_view.dart';

class CustomerSignatureSection extends StatelessWidget {
  const CustomerSignatureSection({
    super.key,
  });

  InvoiceController get controller => Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Obx(() {
      // Decode base64 to bytes for display
      Uint8List? signatureBytes;
      if (controller.customerSignature.value.isNotEmpty) {
        try {
          signatureBytes = base64Decode(controller.customerSignature.value);
        } catch (e) {
          debugPrint('Error decoding signature: $e');
        }
      }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Signature',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.sp),
        GestureDetector(
          onTap: () async {
            final result = await Get.to(
              () => CustomerSignatureView(
                existingSignature: controller.customerSignature.value.isNotEmpty
                    ? controller.customerSignature.value
                    : null,
              ),
            );
            if (result != null) {
              controller.customerSignature.value = result;
            }
          },
          child: Container(
            width: double.infinity,
            height: 150.sp,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: signatureBytes != null
                    ? theme.primaryColor
                    : Colors.grey[400]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: signatureBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(7.r),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.memory(
                            signatureBytes,
                            fit: BoxFit.contain,
                            height: 140.sp,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8.sp,
                          right: 8.sp,
                          child: Container(
                            padding: EdgeInsets.all(6.sp),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.draw,
                          size: 40.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8.sp),
                        Text(
                          'Tap to add signature',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.sp),
        Text(
          'Date: ${DateTime.now().toString().split(' ')[0]}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
    });
  }
}

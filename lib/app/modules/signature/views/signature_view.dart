import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:xinator_fsm_pro/app/modules/signature/controllers/signature_controller.dart';

class SignatureScreen extends GetView<SignatureGetxController> {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signature")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Signature(
                controller: controller.signatrueController.value,
                height: 300,
                width: 300,
                backgroundColor: Colors.grey[200]!,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.signatrueController.value.clear();
                    controller.savedImageFile(null);
                  },
                  child: const Text("Clear"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => controller.saveSignature(context),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

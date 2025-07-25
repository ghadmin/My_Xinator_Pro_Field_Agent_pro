import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SignatureGetxController extends GetxController {
  final signatrueController = Rx<SignatureController>(SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  ));

  final savedImageFile = Rx<File?>(null);
  Future<void> saveSignature(BuildContext context) async {
    if (signatrueController.value.isNotEmpty) {
      final signatureImage = await signatrueController.value.toImage();

      const double width = 300;
      const double height = 340;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw white background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

      // Draw signature
      canvas.drawImage(signatureImage!, Offset(0, 0), Paint());

      // Draw date
      final textPainter = TextPainter(
        text: TextSpan(
          text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          style: const TextStyle(color: Colors.black, fontSize: 25),
        ),
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: width);
      textPainter.paint(canvas, const Offset(10, 310));

      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(pngBytes);

        savedImageFile(file);

        Get.back();
      }
    }
  }
}

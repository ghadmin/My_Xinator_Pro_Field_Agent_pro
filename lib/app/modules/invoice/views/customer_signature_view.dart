import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerSignatureView extends StatefulWidget {
  final String? existingSignature; // Base64 encoded string

  const CustomerSignatureView({
    super.key,
    this.existingSignature,
  });

  @override
  State<CustomerSignatureView> createState() => _CustomerSignatureViewState();
}

class _CustomerSignatureViewState extends State<CustomerSignatureView> {
  final GlobalKey signatureKey = GlobalKey();
  final List<Offset> points = [];
  final List<List<Offset>> strokes = [];
  bool hasSignature = false;
  bool _hasCleared = false; // Track if user cleared the signature

  Uint8List? getExistingSignatureBytes() {
    if (widget.existingSignature == null || widget.existingSignature!.isEmpty) {
      return null;
    }
    try {
      return base64Decode(widget.existingSignature!);
    } catch (e) {
      debugPrint('Error decoding base64 signature: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingSignature != null &&
        widget.existingSignature!.isNotEmpty) {
      hasSignature = true;
    }
  }

  void _clearSignature() {
    setState(() {
      points.clear();
      strokes.clear();
      hasSignature = false;
      _hasCleared = true; // Mark that user has cleared
    });
  }

  Future<String?> _captureSignatureAsBase64() async {
    try {
      RenderRepaintBoundary boundary = signatureKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final uint8List = byteData.buffer.asUint8List();
        return base64Encode(uint8List);
      }
    } catch (e) {
      debugPrint('Error capturing signature: $e');
    }
    return null;
  }

  void _saveAndGoBack() async {
    if (strokes.isEmpty) {
      Get.back(result: null);
      return;
    }

    final signatureBase64 = await _captureSignatureAsBase64();
    if (signatureBase64 != null) {
      Get.back(result: signatureBase64);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Customer Signature'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Please sign in the area below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          key: signatureKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: getExistingSignatureBytes() != null &&
                                      strokes.isEmpty &&
                                      !_hasCleared
                                  ? null
                                  : Border.all(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: GestureDetector(
                                onPanStart: (details) {
                                  if (!hasSignature) {
                                    setState(() {
                                      strokes.add([details.localPosition]);
                                    });
                                  }
                                },
                                onPanUpdate: (details) {
                                  if (!hasSignature) {
                                    setState(() {
                                      strokes.last.add(details.localPosition);
                                    });
                                  }
                                },
                                onPanEnd: (_) {
                                  if (!hasSignature) {
                                    setState(() {
                                      hasSignature = true;
                                    });
                                  }
                                },
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: SignaturePainter(strokes: strokes),
                                  child: getExistingSignatureBytes() != null &&
                                          strokes.isEmpty &&
                                          !_hasCleared
                                      ? Padding(
                                          padding: EdgeInsets.all(16.sp),
                                          child: Image.memory(
                                            getExistingSignatureBytes()!,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Clear button outside RepaintBoundary so it doesn't get captured
                        if (strokes.isNotEmpty ||
                            getExistingSignatureBytes() != null ||
                            _hasCleared)
                          Positioned(
                            top: 16.sp + 8.sp, // Adjust for padding
                            right: 16.sp + 8.sp,
                            child: GestureDetector(
                              onTap: _clearSignature,
                              child: Container(
                                padding: EdgeInsets.all(8.sp),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.replay,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sp),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.sp,
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: SizedBox(
                          height: 48.sp,
                          child: ElevatedButton(
                            onPressed: (strokes.isNotEmpty ||
                                    (getExistingSignatureBytes() != null &&
                                        !_hasCleared))
                                ? _saveAndGoBack
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text('Save'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

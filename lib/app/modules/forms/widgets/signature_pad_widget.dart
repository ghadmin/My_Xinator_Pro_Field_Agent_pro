import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePadWidget extends StatefulWidget {
  final String? initialSignature;

  const SignaturePadWidget({
    super.key,
    this.initialSignature,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final GlobalKey _signatureKey = GlobalKey();
  final List<Offset> _points = [];
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _hasSignature = widget.initialSignature != null &&
        widget.initialSignature!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _clearSignature,
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: _hasSignature ? _saveSignature : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _hasSignature ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: SignaturePainter(_points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sign above',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    setState(() {
      _points.add(localPosition);
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    setState(() {
      _points.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(Offset.zero);
    });
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
      _hasSignature = false;
    });
  }

  Future<void> _saveSignature() async {
    try {
      final boundary =
          _signatureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final base64String = base64Encode(byteData.buffer.asUint8List());
        if (mounted) {
          Navigator.pop(context, base64String);
        }
      }
    } catch (e) {
      debugPrint('Error saving signature: $e');
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

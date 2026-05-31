import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import 'package:myxinator_pro_field_agent_pro/app/providers/signature_provider.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/light_theme_colors.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

/// Signature Dialog
///
/// Modal dialog for capturing signatures with Draw and Type tabs
class SignatureDialogModal extends StatefulWidget {
  /// Title for the signature dialog
  final String title;

  /// Callback when signature is saved
  final Function(String signatureBase64, String fullName)? onSignatureSaved;

  const SignatureDialogModal({
    super.key,
    this.title = 'Signature',
    this.onSignatureSaved,
  });

  @override
  State<SignatureDialogModal> createState() => _SignatureDialogModalState();
}

class _SignatureDialogModalState extends State<SignatureDialogModal>
    with SingleTickerProviderStateMixin {
  late SignatureProvider _provider;

  // Signature controller for Draw tab
  late SignatureController _signatureController;

  // Text editing controller for Type tab
  late TextEditingController _nameController;

  // Tab controller
  late TabController _tabController;

  // Global key for capturing typed signature as image
  final GlobalKey _typedSignatureKey = GlobalKey();

  // Signature ID timestamp (captured once)
  late final int _signatureId;

  @override
  void initState() {
    super.initState();

    // Initialize signature ID timestamp once
    _signatureId = DateTime.now().millisecondsSinceEpoch;

    // Initialize provider
    _provider = Get.put(SignatureProvider());

    // Initialize signature controller
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      onDrawStart: () => kLog('Drawing started'),
      onDrawEnd: () => _onDrawingEnd(),
    );

    // Initialize text controller
    _nameController = TextEditingController();

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Clear signature after a short delay to ensure controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSignature();
    });
  }

  /// Clear the signature canvas and provider data
  void _clearSignature() {
    _signatureController.clear();
    _provider.clearDrawnSignature();
    _nameController.clear();
    _provider.fullName.value = '';
    kLog('Signature cleared');
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _nameController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _provider.currentTabIndex.value = _tabController.index;
    }
  }

  void _onDrawingEnd() {
    // Export signature when drawing ends
    _exportDrawnSignature();
  }

  Future<void> _exportDrawnSignature() async {
    if (_signatureController.isNotEmpty) {
      final data = await _signatureController.toPngBytes();
      if (data != null) {
        final base64 = 'data:image/png;base64,${base64Encode(data)}';
        _provider.updateDrawnSignature(base64);
        kLog('Signature exported: ${base64.length} characters');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 600.w,
        height: 700.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Tabs
            _buildTabs(),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDrawTab(), _buildTypeTab()],
              ),
            ),

            // Action buttons
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: LightThemeColors.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TabBar(
        controller: _tabController,
        labelColor: LightThemeColors.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: LightThemeColors.primaryColor,
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Draw'),
          Tab(text: 'Type'),
        ],
      ),
    );
  }

  Widget _buildDrawTab() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Signature canvas
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
                height: 300.h,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Clear button
          Obx(
            () => ElevatedButton.icon(
              onPressed: _provider.drawnSignatureData.isNotEmpty
                  ? _clearSignature
                  : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Canvas'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full name input
            Text(
              'FULL NAME',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _nameController,
              onChanged: _provider.updateFullName,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Font selection
            Text(
              'Select Font Style',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12.h),
            _buildFontGrid(),

            SizedBox(height: 24.h),

            // Signature preview
            Obx(
              () => _provider.fullName.isNotEmpty
                  ? _buildSignaturePreview()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontGrid() {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: SignatureProvider.fontNames.length,
        itemBuilder: (context, index) {
          final fontName = SignatureProvider.fontNames[index];
          final googleFontName = SignatureProvider.getGoogleFontName(fontName);

          return Obx(() {
            final isSelected = _provider.selectedFont.value == fontName;

            return GestureDetector(
              onTap: () => _provider.selectFont(fontName),
              child: Container(
                width: 120.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? LightThemeColors.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? LightThemeColors.primaryColor
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      fontName,
                      style: GoogleFonts.getFont(
                        googleFontName,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? LightThemeColors.primaryColor
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSignaturePreview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signature Preview',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16.h),

          // Signature text preview
          Obx(() {
            final fontName = _provider.selectedFont.value;
            final googleFontName = SignatureProvider.getGoogleFontName(
              fontName,
            );
            final fullName = _provider.fullName.value;

            return RepaintBoundary(
              key: _typedSignatureKey,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.getFont(
                        googleFontName,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'ID: $_signatureId',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          // Clear button
          TextButton(
            onPressed: _clearSignature,
            child: Text('Clear', style: TextStyle(fontSize: 14.sp)),
          ),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),

          // Save button
          Obx(
            () => ElevatedButton(
              onPressed:
                  (_provider.currentTabIndex.value == 0 &&
                          _provider.drawnSignatureData.isEmpty) ||
                      (_provider.currentTabIndex.value == 1 &&
                          _provider.fullName.isEmpty)
                  ? null
                  : _saveSignature,
              style: ElevatedButton.styleFrom(
                backgroundColor: LightThemeColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _provider.isLoading.value
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSignature() async {
    if (_tabController.index == 1 && _provider.fullName.isNotEmpty) {
      // For typed signatures, capture the text widget as an image
      try {
        // Capture the typed signature widget as an image
        final signatureImage = await _captureTypedSignature();

        if (signatureImage != null) {
          _provider.setSignatureImageData(signatureImage);
          final success = await _provider.saveSignature();

          if (success && mounted) {
            widget.onSignatureSaved?.call(
              signatureImage,
              _provider.fullName.value,
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to capture signature')),
            );
          }
        }
      } catch (e) {
        kLog('Error capturing typed signature: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else if (_tabController.index == 0) {
      // For drawn signatures, make sure we export it
      await _exportDrawnSignature();

      if (_provider.drawnSignatureData.value.isNotEmpty) {
        final success = await _provider.saveSignature();

        if (success && mounted) {
          widget.onSignatureSaved?.call(_provider.drawnSignatureData.value, '');
          Navigator.pop(context, true);
        }
      } else {
        // Show error if no signature
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please draw your signature')),
          );
        }
      }
    }
  }

  /// Capture the typed signature widget as an image
  Future<String?> _captureTypedSignature() async {
    try {
      // Find the RenderRepaintBoundary
      RenderRepaintBoundary? boundary =
          _typedSignatureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        kLog('Failed to find RenderRepaintBoundary');
        return null;
      }

      // Capture the widget as an image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        kLog('Failed to get byte data');
        return null;
      }

      // Convert to base64
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final base64String = base64Encode(pngBytes);

      kLog('Typed signature captured: ${base64String.length} characters');
      return 'data:image/png;base64,$base64String';
    } catch (e) {
      kLog('Error capturing typed signature: $e');
      return null;
    }
  }
}

/// Show signature dialog
Future<bool?> showSignatureDialog({
  required BuildContext context,
  String title = 'Signature',
  Function(String signatureBase64, String fullName)? onSignatureSaved,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) =>
        SignatureDialogModal(title: title, onSignatureSaved: onSignatureSaved),
  );
}

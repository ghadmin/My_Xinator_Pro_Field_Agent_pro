import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../config/theme/light_theme_colors.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/equipment_model.dart';

/// Reusable Equipment Form Modal/Bottom Sheet
/// Displays a form for creating or editing equipment
class EquipmentFormModal extends StatefulWidget {
  /// Existing equipment data for edit mode (null for create mode)
  final EquipmentModel? equipment;

  const EquipmentFormModal({super.key, this.equipment});

  @override
  State<EquipmentFormModal> createState() => _EquipmentFormModalState();

  /// Show the modal and return the created/updated equipment
  static Future<EquipmentModel?> show({
    required BuildContext context,
    EquipmentModel? equipment,
  }) {
    return showModalBottomSheet<EquipmentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EquipmentFormModal(equipment: equipment),
    );
  }
}

class _EquipmentFormModalState extends State<EquipmentFormModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text editing controllers
  late final TextEditingController _serialNumberController;
  late final TextEditingController _typeController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _skuController;
  late final TextEditingController _notesController;

  // Focus nodes
  late final FocusNode _serialNumberFocusNode;
  late final FocusNode _typeFocusNode;
  late final FocusNode _makeFocusNode;
  late final FocusNode _modelFocusNode;
  late final FocusNode _skuFocusNode;
  late final FocusNode _notesFocusNode;

  // Date values
  DateTime? _warrantyStart;
  DateTime? _warrantyEnd;
  DateTime? _laborWarrantyStart;
  DateTime? _laborWarrantyEnd;
  DateTime? _installDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
  }

  void _initializeControllers() {
    if (widget.equipment != null) {
      // Edit mode - prefill with existing data
      final eq = widget.equipment!;
      _serialNumberController = TextEditingController(text: eq.serialNumber);
      _typeController = TextEditingController(text: eq.type);
      _makeController = TextEditingController(text: eq.make ?? '');
      _modelController = TextEditingController(text: eq.model ?? '');
      _skuController = TextEditingController(text: eq.sku ?? '');
      _notesController = TextEditingController(text: eq.notes ?? '');
      // Parse date strings to DateTime
      _warrantyStart = _parseDate(eq.warrantyStart);
      _warrantyEnd = _parseDate(eq.warrantyEnd);
      _laborWarrantyStart = _parseDate(eq.laborWarrantyStart);
      _laborWarrantyEnd = _parseDate(eq.laborWarrantyEnd);
      _installDate = _parseDate(eq.installDate);
    } else {
      // Create mode - empty controllers
      _serialNumberController = TextEditingController();
      _typeController = TextEditingController();
      _makeController = TextEditingController();
      _modelController = TextEditingController();
      _skuController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  /// Helper to parse date string to DateTime
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Try parsing MM/dd/yyyy format first (from API)
      if (dateStr.contains('/') && dateStr.split('/').length == 3) {
        final parts = dateStr.split('/');
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[0]), // month
          int.parse(parts[1]), // day
        );
      }
      // Try ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  void _initializeFocusNodes() {
    _serialNumberFocusNode = FocusNode();
    _typeFocusNode = FocusNode();
    _makeFocusNode = FocusNode();
    _modelFocusNode = FocusNode();
    _skuFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
  }

  void _unfocusAllFields() {
    _serialNumberFocusNode.unfocus();
    _typeFocusNode.unfocus();
    _makeFocusNode.unfocus();
    _modelFocusNode.unfocus();
    _skuFocusNode.unfocus();
    _notesFocusNode.unfocus();
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _typeController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _skuController.dispose();
    _notesController.dispose();
    _serialNumberFocusNode.dispose();
    _typeFocusNode.dispose();
    _makeFocusNode.dispose();
    _modelFocusNode.dispose();
    _skuFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate({
    required DateTime? currentDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final now = DateTime.now();
    final initialDate = currentDate ?? now;
    final firstDate = DateTime(now.year - 50);
    final lastDate = DateTime(now.year + 50);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LightThemeColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  void _saveEquipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create the equipment model
    final equipment = EquipmentModel(
      id: widget.equipment?.id,
      serialNumber: _serialNumberController.text.trim(),
      type: _typeController.text.trim(),
      make: _makeController.text.trim().isEmpty
          ? null
          : _makeController.text.trim(),
      model: _modelController.text.trim().isEmpty
          ? null
          : _modelController.text.trim(),
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      warrantyStart: _warrantyStart?.toIso8601String(),
      warrantyEnd: _warrantyEnd?.toIso8601String(),
      laborWarrantyStart: _laborWarrantyStart?.toIso8601String(),
      laborWarrantyEnd: _laborWarrantyEnd?.toIso8601String(),
      installDate: _installDate?.toIso8601String(),
      notes: _notesController.text.trim().isEmpty
          ? ''
          : _notesController.text.trim(),
      createdAt: widget.equipment?.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Call API to save or update equipment
    final controller = Get.find<AppointmentController>();
    final isEditMode = widget.equipment != null && widget.equipment!.id != null;

    if (isEditMode) {
      await controller.updateEquipment(equipment);
    } else {
      await controller.saveEquipment(equipment);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(equipment);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.equipment != null;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: _unfocusAllFields,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditMode ? 'Edit Equipment' : 'Add Equipment',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Divider(height: 1.h, color: Colors.grey[200]),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Serial Number (Required)
                        _buildSectionTitle('Serial Number *'),
                        _buildTextFormField(
                          controller: _serialNumberController,
                          focusNode: _serialNumberFocusNode,
                          hintText: 'Enter serial number',
                          prefixIcon: Icons.tag,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Serial number is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Type (Required)
                        _buildSectionTitle('Type *'),
                        _buildTextFormField(
                          controller: _typeController,
                          focusNode: _typeFocusNode,
                          hintText: 'Enter equipment type',
                          prefixIcon: Icons.category,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Type is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Make
                        _buildSectionTitle('Make'),
                        _buildTextFormField(
                          controller: _makeController,
                          focusNode: _makeFocusNode,
                          hintText: 'Enter manufacturer',
                          prefixIcon: Icons.business,
                        ),
                        SizedBox(height: 16.h),

                        // Model
                        _buildSectionTitle('Model'),
                        _buildTextFormField(
                          controller: _modelController,
                          focusNode: _modelFocusNode,
                          hintText: 'Enter model number',
                          prefixIcon: Icons.settings,
                        ),
                        SizedBox(height: 16.h),

                        // SKU
                        _buildSectionTitle('SKU'),
                        _buildTextFormField(
                          controller: _skuController,
                          focusNode: _skuFocusNode,
                          hintText: 'Enter SKU',
                          prefixIcon: Icons.scanner,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        SizedBox(height: 16.h),

                        // Warranty Section
                        _buildSectionHeader('Warranty Information'),
                        SizedBox(height: 8.h),

                        // Warranty Start
                        _buildDateSelector(
                          label: 'Warranty Start',
                          date: _warrantyStart,
                          onTap: () {
                            _selectDate(
                              currentDate: _warrantyStart,
                              onDateSelected: (date) => _warrantyStart = date,
                            );
                          },
                        ),
                        SizedBox(height: 12.h),

                        // Warranty End
                        _buildDateSelector(
                          label: 'Warranty End',
                          date: _warrantyEnd,
                          onTap: () {
                            _selectDate(
                              currentDate: _warrantyEnd,
                              onDateSelected: (date) => _warrantyEnd = date,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Labor Warranty Section
                        _buildSectionHeader('Labor Warranty'),
                        SizedBox(height: 8.h),

                        // Labor Warranty Start
                        _buildDateSelector(
                          label: 'Labor Warranty Start',
                          date: _laborWarrantyStart,
                          onTap: () {
                            _selectDate(
                              currentDate: _laborWarrantyStart,
                              onDateSelected: (date) =>
                                  _laborWarrantyStart = date,
                            );
                          },
                        ),
                        SizedBox(height: 12.h),

                        // Labor Warranty End
                        _buildDateSelector(
                          label: 'Labor Warranty End',
                          date: _laborWarrantyEnd,
                          onTap: () {
                            _selectDate(
                              currentDate: _laborWarrantyEnd,
                              onDateSelected: (date) =>
                                  _laborWarrantyEnd = date,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Install Date
                        _buildSectionHeader('Installation'),
                        SizedBox(height: 8.h),
                        _buildDateSelector(
                          label: 'Install Date',
                          date: _installDate,
                          onTap: () {
                            _selectDate(
                              currentDate: _installDate,
                              onDateSelected: (date) => _installDate = date,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Notes
                        _buildSectionTitle('Notes'),
                        _buildTextFormField(
                          controller: _notesController,
                          focusNode: _notesFocusNode,
                          hintText: 'Add any additional notes...',
                          prefixIcon: Icons.note,
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Save Button
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEquipment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightThemeColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Equipment' : 'Save Equipment',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: LightThemeColors.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: LightThemeColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        prefixIcon: Icon(prefixIcon, size: 20.sp, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20.sp, color: Colors.grey[600]),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: date != null ? Colors.black87 : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 24.sp, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

/// Equipment Card Widget for displaying equipment in a list
class EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: LightThemeColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.precision_manufacturing,
                        color: LightThemeColors.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.make != null && equipment.model != null
                                ? '${equipment.make} ${equipment.model}'
                                : equipment.type,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'SN: ${equipment.serialNumber}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                // Show Type and Notes instead of warranty/installed dates
                if (equipment.type.isNotEmpty || equipment.notes != null) ...[
                  SizedBox(height: 12.h),
                  Divider(height: 1.h, color: Colors.grey[200]),
                  SizedBox(height: 12.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (equipment.type.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 14.sp,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Type: ${equipment.type}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (equipment.notes != null &&
                          equipment.notes!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note,
                                size: 14.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  equipment.notes!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

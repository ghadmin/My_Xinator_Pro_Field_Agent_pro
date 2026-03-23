import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../config/theme/light_theme_colors.dart';
import '../../../../components/global-widgets/text_widget.dart';
import '../../../../components/global-widgets/my_snackbar.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/equipment_model.dart';
import '../../models/equipment_type_model.dart';

/// Equipment Form Modal Bottom Sheet
/// Shows a form to add or edit equipment with all required fields
class EquipmentFormModal extends StatefulWidget {
  final EquipmentModel? equipment; // null for add, non-null for edit
  final List<EquipmentTypeModel> equipmentTypes;

  const EquipmentFormModal({
    super.key,
    this.equipment,
    required this.equipmentTypes,
  });

  @override
  State<EquipmentFormModal> createState() => _EquipmentFormModalState();
}

class _EquipmentFormModalState extends State<EquipmentFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'serialNumber': TextEditingController(
        text: widget.equipment?.serialNumber ?? '',
      ),
      'type': TextEditingController(text: widget.equipment?.type ?? ''),
      'make': TextEditingController(text: widget.equipment?.make ?? ''),
      'model': TextEditingController(text: widget.equipment?.model ?? ''),
      'sku': TextEditingController(text: widget.equipment?.sku ?? ''),
      'warrantyStart': TextEditingController(
        text: widget.equipment?.warrantyStart ?? '',
      ),
      'warrantyEnd': TextEditingController(
        text: widget.equipment?.warrantyEnd ?? '',
      ),
      'laborWarrantyStart': TextEditingController(
        text: widget.equipment?.laborWarrantyStart ?? '',
      ),
      'laborWarrantyEnd': TextEditingController(
        text: widget.equipment?.laborWarrantyEnd ?? '',
      ),
      'installDate': TextEditingController(
        text: widget.equipment?.installDate ?? '',
      ),
      'notes': TextEditingController(text: widget.equipment?.notes ?? ''),
    };

    _focusNodes = _controllers.keys.fold<Map<String, FocusNode>>({}, (
      map,
      key,
    ) {
      map[key] = FocusNode();
      return map;
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    _focusNodes.forEach((key, node) => node.dispose());
    super.dispose();
  }

  void _submitForm() {
    final controller = Get.find<AppointmentController>();

    // Find the equipmentTypeId from the selected type description
    final selectedType = widget.equipmentTypes.firstWhereOrNull(
      (t) => t.equipmentTypeDesc == _controllers['type']!.text,
    );

    // Create or update equipment
    final equipment = EquipmentModel(
      id:
          widget.equipment?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      serialNumber: _controllers['serialNumber']!.text,
      type: _controllers['type']!.text,
      equipmentTypeId: selectedType?.equipmentTypeId,
      make: _controllers['make']!.text.isEmpty
          ? null
          : _controllers['make']!.text,
      model: _controllers['model']!.text.isEmpty
          ? null
          : _controllers['model']!.text,
      barcode: null,
      sku: _controllers['sku']!.text.isEmpty ? null : _controllers['sku']!.text,
      warrantyStart: _controllers['warrantyStart']!.text.isEmpty
          ? null
          : _controllers['warrantyStart']!.text,
      warrantyEnd: _controllers['warrantyEnd']!.text.isEmpty
          ? null
          : _controllers['warrantyEnd']!.text,
      laborWarrantyStart: _controllers['laborWarrantyStart']!.text.isEmpty
          ? null
          : _controllers['laborWarrantyStart']!.text,
      laborWarrantyEnd: _controllers['laborWarrantyEnd']!.text.isEmpty
          ? null
          : _controllers['laborWarrantyEnd']!.text,
      installDate: _controllers['installDate']!.text.isEmpty
          ? null
          : _controllers['installDate']!.text,
      notes: _controllers['notes']!.text.isEmpty
          ? null
          : _controllers['notes']!.text,
      createdAt:
          widget.equipment?.createdAt ?? DateTime.now().toIso8601String(),
    );

    // Add or update in local list
    controller.updateEquipment(equipment);
  }

  Future<void> _selectDate(String fieldKey) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _controllers[fieldKey]!.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return GestureDetector(
      onTap: () {
        // Close keyboard when tapping outside
        _focusNodes.forEach((key, node) => node.unfocus());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      TextWidget(
                        text: widget.equipment == null
                            ? 'Add Equipment'
                            : 'Edit Equipment',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // Serial Number (Required)
                        _buildTextField(
                          key: 'serialNumber',
                          label: 'Serial Number',
                          hint: 'Enter serial number',
                          required: true,
                        ),

                        // Type (Required)
                        _buildTypeDropdown(theme),

                        // Make
                        _buildTextField(
                          key: 'make',
                          label: 'Make',
                          hint: 'Enter make (optional)',
                        ),

                        // Model
                        _buildTextField(
                          key: 'model',
                          label: 'Model',
                          hint: 'Enter model (optional)',
                        ),

                        // SKU
                        _buildTextField(
                          key: 'sku',
                          label: 'SKU',
                          hint: 'Enter SKU (optional)',
                        ),

                        // Warranty Start
                        _buildDateField(
                          key: 'warrantyStart',
                          label: 'Warranty Start',
                          hint: 'Select warranty start date',
                        ),

                        // Warranty End
                        _buildDateField(
                          key: 'warrantyEnd',
                          label: 'Warranty End',
                          hint: 'Select warranty end date',
                        ),

                        // Labor Warranty Start
                        _buildDateField(
                          key: 'laborWarrantyStart',
                          label: 'Labor Warranty Start',
                          hint: 'Select labor warranty start date',
                        ),

                        // Labor Warranty End
                        _buildDateField(
                          key: 'laborWarrantyEnd',
                          label: 'Labor Warranty End',
                          hint: 'Select labor warranty end date',
                        ),

                        // Install Date
                        _buildDateField(
                          key: 'installDate',
                          label: 'Install Date',
                          hint: 'Select install date',
                        ),

                        // Notes
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            controller: _controllers['notes'],
                            focusNode: _focusNodes['notes'],
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              hintText: 'Enter any additional notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Submit button
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightThemeColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: TextWidget(
                        text: widget.equipment == null
                            ? 'Add Equipment'
                            : 'Update Equipment',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String key,
    required String label,
    required String hint,
    bool required = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: _controllers[key],
        focusNode: _focusNodes[key],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(16.w),
          suffixIcon: required
              ? const Text('*', style: TextStyle(color: Colors.red))
              : null,
        ),
        validator: required
            ? (value) =>
                  value == null || value.isEmpty ? '$label is required' : null
            : null,
        inputFormatters: key == 'serialNumber'
            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
            : null,
      ),
    );
  }

  Widget _buildTypeDropdown(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: FormField<String>(
        initialValue: _controllers['type']!.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Type is required' : null,
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showTypeSelector(),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    hintText: 'Select equipment type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.all(16.w),
                    errorText: state.hasError ? state.errorText : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _controllers['type']!.text.isEmpty
                              ? 'Select equipment type'
                              : _controllers['type']!.text,
                          style: TextStyle(
                            color: _controllers['type']!.text.isEmpty
                                ? Colors.grey[600]
                                : Colors.black87,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                      const Text('*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required String key,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () => _selectDate(key),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _controllers[key]!.text.isEmpty
                      ? hint
                      : _formatDateDisplay(_controllers[key]!.text),
                  style: TextStyle(
                    color: _controllers[key]!.text.isEmpty
                        ? Colors.grey[600]
                        : Colors.black87,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeSelector() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    TextWidget(
                      text: 'Select Equipment Type',
                      style: Get.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Type list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.equipmentTypes.length,
                  separatorBuilder: (_, __) => Divider(height: 1.h),
                  itemBuilder: (context, index) {
                    final type = widget.equipmentTypes[index];
                    return ListTile(
                      title: Text(type.equipmentTypeDesc),
                      onTap: () {
                        setState(() {
                          _controllers['type']!.text = type.equipmentTypeDesc;
                        });
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatDateDisplay(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

/// Equipment Card Widget
/// Displays equipment information in a card format (read-only)
class EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback? onTap;

  const EquipmentCard({super.key, required this.equipment, this.onTap});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  bool _isWarrantyValid() {
    if (equipment.warrantyEnd == null || equipment.warrantyEnd!.isEmpty) {
      return true;
    }
    try {
      final endDate = DateTime.parse(equipment.warrantyEnd!);
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWarrantyValid = _isWarrantyValid();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isWarrantyValid ? Colors.grey[200]! : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with serial number
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.serialNumber,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (equipment.type.isNotEmpty)
                          Text(
                            equipment.type,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isWarrantyValid)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20.sp,
                    ),
                ],
              ),

              // Make, Model, SKU
              if (equipment.make != null ||
                  equipment.model != null ||
                  equipment.sku != null) ...[
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 8.h,
                  children: [
                    if (equipment.make != null && equipment.make!.isNotEmpty)
                      _buildInfoChip(Icons.business, equipment.make!),
                    if (equipment.model != null && equipment.model!.isNotEmpty)
                      _buildInfoChip(Icons.category, equipment.model!),
                    if (equipment.sku != null && equipment.sku!.isNotEmpty)
                      _buildInfoChip(Icons.tag, equipment.sku!),
                  ],
                ),
              ],

              // Dates
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    isWarrantyValid
                        ? Icons.verified
                        : Icons.warning_amber_rounded,
                    size: 14.sp,
                    color: isWarrantyValid ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Warranty: ${_formatDate(equipment.warrantyStart)} - ${_formatDate(equipment.warrantyEnd)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              if (equipment.installDate != null &&
                  equipment.installDate!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.event, size: 14.sp, color: Colors.grey[400]),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Installed: ${_formatDate(equipment.installDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Notes
              if (equipment.notes != null && equipment.notes!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    equipment.notes!,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    maxLines: null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[500]),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

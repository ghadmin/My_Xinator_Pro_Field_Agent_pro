import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/equipment/controllers/equipment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/equipment/models/equipment_model.dart';
import '../../../../../config/theme/light_theme_colors.dart';
import '../../../../components/global-widgets/text_widget.dart';
import '../../controllers/appointment_controller.dart';

/// Equipment Form Modal Bottom Sheet
/// Shows a form to add or edit equipment with all required fields
class EquipmentFormModal extends StatefulWidget {
  final Equipment? equipment; // null for add, non-null for edit
  final List<EquipmentType> equipmentTypes;

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
      'type': TextEditingController(
        text: widget.equipment?.equipmentType ?? '',
      ),
      'make': TextEditingController(text: widget.equipment?.make ?? ''),
      'model': TextEditingController(text: widget.equipment?.model ?? ''),
      'barcode': TextEditingController(text: widget.equipment?.barcode ?? ''),
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

  void _submitForm() async {
    final controller = Get.find<AppointmentController>();
    final equipmentController = Get.find<EquipmentController>();

    // Find the equipmentTypeId from the selected type description
    final selectedType = widget.equipmentTypes.firstWhereOrNull(
      (t) => t.typeName == _controllers['type']!.text,
    );

    // Create or update equipment
    final equipment = Equipment(
      id: widget.equipment?.id ?? DateTime.now().millisecondsSinceEpoch,
      siteId: 0, // Will be set by the controller
      customerGuid: '', // Will be set by the controller
      customerId: '', // Will be set by the controller
      customerName: '', // Will be set by the controller
      serialNumber: _controllers['serialNumber']!.text.isEmpty
          ? null
          : _controllers['serialNumber']!.text,
      equipmentType: _controllers['type']!.text.isEmpty
          ? null
          : _controllers['type']!.text,
      equipmentTypeId: selectedType?.id != null
          ? int.parse(selectedType?.id ?? "0")
          : null,
      make: _controllers['make']!.text.isEmpty
          ? null
          : _controllers['make']!.text,
      model: _controllers['model']!.text.isEmpty
          ? null
          : _controllers['model']!.text,
      barcode: _controllers['barcode']!.text.isEmpty
          ? null
          : _controllers['barcode']!.text,
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
      createdDateTime:
          widget.equipment?.createdDateTime ?? DateTime.now().toIso8601String(),
    );

    // Get appointment details for required parameters
    final appointment = controller.selectedAppointment.value;
    if (appointment == null) {
      Get.snackbar(
        'Error',
        'Appointment information not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final customerId = appointment.customerID?.toString() ?? '';
    final customerGuid = appointment.customer?.customerGuid ?? '';
    final siteId = int.tryParse(appointment.siteID ?? '') ?? 0;
    final companyId = appointment.companyID;

    // Add or update equipment
    bool success;
    if (widget.equipment != null) {
      // Update existing equipment
      success = await equipmentController.updateEquipment(
        id: widget.equipment!.id,
        customerId: customerId,
        customerGuid: customerGuid,
        siteId: siteId,
        make: equipment.make,
        model: equipment.model,
        notes: equipment.notes,
        equipmentTypeId: equipment.equipmentTypeId,
        barcode: equipment.barcode,
        serialNumber: equipment.serialNumber,
        warrantyStart: equipment.warrantyStart,
        warrantyEnd: equipment.warrantyEnd,
        laborWarrantyStart: equipment.laborWarrantyStart,
        laborWarrantyEnd: equipment.laborWarrantyEnd,
        installDate: equipment.installDate,
        companyId: companyId,
      );
    } else {
      // Create new equipment
      success = await equipmentController.createEquipment(
        customerId: customerId,
        customerGuid: customerGuid,
        siteId: siteId,
        make: equipment.make,
        model: equipment.model,
        notes: equipment.notes,
        equipmentTypeId: equipment.equipmentTypeId,
        barcode: equipment.barcode,
        serialNumber: equipment.serialNumber,
        warrantyStart: equipment.warrantyStart,
        warrantyEnd: equipment.warrantyEnd,
        laborWarrantyStart: equipment.laborWarrantyStart,
        laborWarrantyEnd: equipment.laborWarrantyEnd,
        installDate: equipment.installDate,
        companyId: companyId,
      );
    }

    // Close the modal only on success
    if (success && mounted) {
      // Use Navigator.pop to close this specific modal
      Navigator.of(context).pop();
    }

    // Close the modal only on success
    if (success) {
      Get.back();
    }
  }

  Future<void> _selectDate(String fieldKey) async {
    // Unfocus all nodes to dismiss keyboard
    _focusNodes.forEach((key, node) => node.unfocus());
    // Small delay to ensure keyboard is fully dismissed
    await Future.delayed(const Duration(milliseconds: 100));

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
              mainAxisSize: MainAxisSize.max,
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

                        // Barcode
                        _buildTextField(
                          key: 'barcode',
                          label: 'Barcode',
                          hint: 'Enter barcode (optional)',
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
    // Unfocus all nodes to dismiss keyboard
    _focusNodes.forEach((key, node) => node.unfocus());

    Get.bottomSheet(
      Container(
        height: Get.height * 0.9, // 90% of screen height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
              Expanded(
                child: ListView.separated(
                  itemCount: widget.equipmentTypes.length,
                  separatorBuilder: (_, __) => Divider(height: 1.h),
                  itemBuilder: (context, index) {
                    final type = widget.equipmentTypes[index];
                    return Material(
                      child: ListTile(
                        title: Text(type.typeName),
                        onTap: () {
                          setState(() {
                            _controllers['type']!.text = type.typeName;
                          });
                          Get.back();
                        },
                      ),
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
  final Equipment equipment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EquipmentCard({
    super.key,
    required this.equipment,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with type badge and actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Equipment Type: ${equipment.equipmentType?.isEmpty == true ? "N/A" : equipment.equipmentType}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Warning icon if warranty invalid
                if (!isWarrantyValid)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                // Action buttons
                if (onEdit != null) SizedBox(width: 4.w),
                if (onEdit != null)
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16.sp,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (onDelete != null) SizedBox(width: 8.w),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, size: 18.sp),
                    color: Colors.red,
                    padding: EdgeInsets.all(4.w),
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // All fields with labels (excluding Type since it's in header)
            _buildSingleDetailRow(
              'Serial Number',
              equipment.serialNumber!.isNotEmpty &&
                      equipment.serialNumber != null
                  ? equipment.serialNumber!
                  : 'N/A',
            ),

            // Make, Model in row
            _buildDetailRow(
              'Make',
              equipment.make?.isNotEmpty == true ? equipment.make! : 'N/A',
              'Model',
              equipment.model?.isNotEmpty == true ? equipment.model! : 'N/A',
            ),

            // // SKU
            // if (equipment.s != null && equipment.sku!.isNotEmpty)
            //   _buildSingleDetailRow('SKU', equipment.sku!),
            SizedBox(height: 12.h),

            // Warranty Dates Section
            _buildDateSection(
              'Warranty',
              equipment.warrantyStart,
              equipment.warrantyEnd,
            ),

            // Labor Warranty Dates Section
            if (equipment.laborWarrantyStart != null ||
                equipment.laborWarrantyEnd != null)
              _buildDateSection(
                'Labor Warranty',
                equipment.laborWarrantyStart,
                equipment.laborWarrantyEnd,
              ),

            // Install Date
            if (equipment.installDate != null &&
                equipment.installDate!.isNotEmpty)
              _buildSingleDetailRow(
                'Install Date',
                _formatDate(equipment.installDate),
              ),

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      equipment.notes!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(child: _buildDetailItem(label1, value1)),
          SizedBox(width: 16.w),
          Expanded(child: _buildDetailItem(label2, value2)),
        ],
      ),
    );
  }

  Widget _buildSingleDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: _buildDetailItem(label, value),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(String label, String? startDate, String? endDate) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey[500]),
              SizedBox(width: 4.w),
              Text(
                '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

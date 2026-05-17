import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  final String id;
  final String? header;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const TextFieldWidget({
    super.key,
    required this.id,
    this.header,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null && header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              header!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        Expanded(
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            readOnly: readOnly,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              filled: readOnly,
              fillColor: readOnly ? Colors.grey[100] : null,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownFieldWidget extends StatefulWidget {
  final String id;
  final String? header;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> options;
  final bool readOnly;

  const DropdownFieldWidget({
    super.key,
    required this.id,
    this.header,
    this.value,
    required this.onChanged,
    required this.options,
    this.readOnly = false,
  });

  @override
  State<DropdownFieldWidget> createState() => _DropdownFieldWidgetState();
}

class _DropdownFieldWidgetState extends State<DropdownFieldWidget> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(DropdownFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null && widget.header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.header!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: widget.options.contains(_selectedValue) ? _selectedValue : null,
            onChanged: widget.readOnly
                ? null
                : (value) {
                    setState(() {
                      _selectedValue = value;
                    });
                    widget.onChanged(value);
                  },
            items: widget.options
                .map((option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option, style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              filled: widget.readOnly,
              fillColor: widget.readOnly ? Colors.grey[100] : null,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class CheckboxFieldWidget extends StatelessWidget {
  final String id;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool readOnly;

  const CheckboxFieldWidget({
    super.key,
    required this.id,
    required this.label,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: readOnly ? null : () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: readOnly ? null : (v) => onChanged(v ?? false),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: readOnly ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignatureFieldWidget extends StatelessWidget {
  final String id;
  final String? header;
  final String? signatureData;
  final VoidCallback onSign;
  final bool readOnly;

  const SignatureFieldWidget({
    super.key,
    required this.id,
    this.header,
    this.signatureData,
    required this.onSign,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null && header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              header!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        Expanded(
          child: GestureDetector(
            onTap: readOnly ? null : onSign,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: signatureData != null ? Colors.green : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
                color: readOnly ? Colors.grey[100] : Colors.white,
              ),
              child: signatureData != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.memory(
                        base64Decode(signatureData!),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.draw,
                            size: 32,
                            color: readOnly ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            readOnly ? 'Signature Required' : 'Tap to Sign',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class SmartFieldWidget extends StatelessWidget {
  final String id;
  final String? header;
  final String value;

  const SmartFieldWidget({
    super.key,
    required this.id,
    this.header,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null && header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              header!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PartsTableWidget extends StatefulWidget {
  final String id;
  final String? header;
  final List<Map<String, String>> rows;
  final ValueChanged<List<Map<String, String>>> onChanged;
  final int maxRows;
  final bool readOnly;

  const PartsTableWidget({
    super.key,
    required this.id,
    this.header,
    required this.rows,
    required this.onChanged,
    this.maxRows = 10,
    this.readOnly = false,
  });

  @override
  State<PartsTableWidget> createState() => _PartsTableWidgetState();
}

class _PartsTableWidgetState extends State<PartsTableWidget> {
  late List<Map<String, String>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.rows.map((row) => Map<String, String>.from(row)).toList();
    if (_rows.isEmpty) {
      _rows.add({'qty': '', 'description': ''});
    }
  }

  void _updateRows() {
    widget.onChanged(_rows);
    setState(() {});
  }

  void _addRow() {
    if (_rows.length < widget.maxRows) {
      setState(() {
        _rows.add({'qty': '', 'description': ''});
      });
      _updateRows();
    }
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows.removeAt(index);
      });
      _updateRows();
    }
  }

  void _updateCell(int rowIndex, String key, String value) {
    setState(() {
      _rows[rowIndex][key] = value;
    });
    _updateRows();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null && widget.header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.header!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                if (!widget.readOnly && _rows.length < widget.maxRows)
                  InkWell(
                    onTap: _addRow,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Add Row',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(30),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    _buildHeaderCell('Qty'),
                    _buildHeaderCell('Description'),
                    if (!widget.readOnly) const SizedBox(),
                  ],
                ),
                ...List.generate(_rows.length, (rowIndex) {
                  return TableRow(
                    children: [
                      _buildQtyCell(rowIndex),
                      _buildDescriptionCell(rowIndex),
                      if (!widget.readOnly) _buildDeleteCell(rowIndex),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQtyCell(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: TextFormField(
        initialValue: _rows[rowIndex]['qty'],
        onChanged: (value) => _updateCell(rowIndex, 'qty', value),
        readOnly: widget.readOnly,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          isDense: true,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionCell(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: TextFormField(
        initialValue: _rows[rowIndex]['description'],
        onChanged: (value) => _updateCell(rowIndex, 'description', value),
        readOnly: widget.readOnly,
        maxLines: null,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDeleteCell(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: _rows.length > 1 ? () => _removeRow(rowIndex) : null,
        child: Icon(
          Icons.close,
          size: 16,
          color: _rows.length > 1 ? Colors.red[400] : Colors.grey[300],
        ),
      ),
    );
  }
}

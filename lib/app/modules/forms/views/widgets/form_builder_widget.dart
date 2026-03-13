import 'package:flutter/material.dart';

class SignatureWidget extends StatelessWidget {
  final VoidCallback onClear;

  const SignatureWidget({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 150,
      width: double.infinity,
      child: Center(child: Text("Signature Area")),
    );
  }
}

class RadioButtonsWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RadioButtonsWidget({super.key, required this.onChanged});

  @override
  State<RadioButtonsWidget> createState() => _RadioButtonsWidgetState();
}

class _RadioButtonsWidgetState extends State<RadioButtonsWidget> {
  String? selectedValue = "Option 1";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<String>(
              activeColor: Colors.blue,
              value: "Option 1",
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
                widget.onChanged(selectedValue!);
              },
            ),
            Text("Option 1"),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              activeColor: Colors.blue,
              value: "Option 2",
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
                widget.onChanged(selectedValue!);
              },
            ),
            Text("Option 2"),
          ],
        ),
      ],
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const CheckboxWidget({super.key, required this.onChanged});

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
            widget.onChanged(isChecked);
          },
        ),
        Text("Check this option"),
      ],
    );
  }
}

class DropdownWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const DropdownWidget({super.key, required this.onChanged});

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? selectedValue = "Option 1";

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      items: [
        DropdownMenuItem(value: "Option 1", child: Text("Option 1")),
        DropdownMenuItem(value: "Option 2", child: Text("Option 2")),
      ],
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });
        widget.onChanged(value!);
      },
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }
}

class DateInputWidget extends StatefulWidget {
  final ValueChanged<String?> onChanged;

  const DateInputWidget({super.key, required this.onChanged});

  @override
  State<DateInputWidget> createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  String? selectedDate = "mm/dd/yyyy";

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = "${picked.month}/${picked.day}/${picked.year}";
      });
      widget.onChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: "mm/dd/yyyy",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _selectDate),
        ],
      ),
    );
  }
}

class NumberInputWidget extends StatelessWidget {
  final ValueChanged<String?> onChanged;

  const NumberInputWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: "Enter number"),
      onChanged: onChanged,
    );
  }
}

class TextAreaWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const TextAreaWidget({
    super.key,
    this.hintText = "Enter text",
    this.onChanged,
  });

  @override
  State<TextAreaWidget> createState() => _TextAreaWidgetState();
}

class _TextAreaWidgetState extends State<TextAreaWidget> {
  double _height = 120; // initial height
  final double _minHeight = 60;
  final double _maxHeight = 400;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: _height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            expands: true, // allows expansion inside container
            maxLines: null,
            minLines: null,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (details) {
            setState(() {
              _height += details.delta.dy;
              if (_height < _minHeight) _height = _minHeight;
              if (_height > _maxHeight) _height = _maxHeight;
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: 16,
            child: Icon(Icons.drag_handle, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class TextInputWidget extends StatelessWidget {
  final ValueChanged<String?> onChanged;

  const TextInputWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(hintText: "Enter text"),
      onChanged: onChanged,
    );
  }
}

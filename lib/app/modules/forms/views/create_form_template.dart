import 'package:flutter/material.dart';
import 'package:xinator_fsm_pro/app/components/global-widgets/text_widget.dart';

class FieldModel {
  String name;
  Icon icon;
  FieldModel({required this.name, required this.icon});
}

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  final List<FieldModel> availableFields = [
    FieldModel(
        name: "Text Input",
        icon: Icon(
          Icons.text_rotation_none_outlined,
          size: 30,
        )),
    FieldModel(
        name: "Text Area", icon: Icon(Icons.short_text_rounded, size: 30)),
    FieldModel(name: "Number", icon: Icon(Icons.numbers, size: 30)),
    FieldModel(name: "Date", icon: Icon(Icons.calendar_today, size: 30)),
    FieldModel(name: "Dropdown", icon: Icon(Icons.arrow_drop_down, size: 30)),
    FieldModel(name: "Checkbox", icon: Icon(Icons.check_box, size: 30)),
    FieldModel(
        name: "Radio Button", icon: Icon(Icons.radio_button_checked, size: 30)),
    FieldModel(name: "Signature", icon: Icon(Icons.brush, size: 30)),
  ];

  final List<String> formFields = [];
  String? selectedField;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(text: "Form Builder"),
      ),
      body: Row(
        children: [
          /// Left - Field Types
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(8),
                children: availableFields
                    .map((field) => Draggable<String>(
                          data: field.name,
                          feedback: Material(
                            child: fieldCard(field, dragging: true),
                          ),
                          childWhenDragging: fieldCard(field, disabled: true),
                          child: fieldCard(field),
                        ))
                    .toList(),
              ),
            ),
          ),

          /// Middle - Form Preview
          Expanded(
            flex: 4,
            child: DragTarget<String>(
              onAccept: (field) {
                setState(() {
                  formFields.add(field);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: candidateData.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        style: BorderStyle.solid),
                  ),
                  child: formFields.isEmpty
                      ? const Center(
                          child: Text(
                            "Drag fields here to build your form",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: formFields.length,
                          itemBuilder: (context, index) {
                            final field = formFields[index];
                            return ListTile(
                              title: Text(field),
                              onTap: () {
                                setState(() {
                                  selectedField = field;
                                });
                              },
                            );
                          },
                        ),
                );
              },
            ),
          ),

          /// Right - Field Properties
        ],
      ),

      /// Bottom Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                debugPrint("Saved fields: $formFields");
              },
              child: const Text("Save Form Structure"),
            ),
          ],
        ),
      ),
    );
  }

  Widget fieldCard(FieldModel field,
      {bool dragging = false, bool disabled = false}) {
    return Card(
      elevation: dragging ? 6 : 2,
      color: disabled ? Colors.grey[300] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            field.icon,
            const SizedBox(width: 10),
            TextWidget(
                text: field.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}

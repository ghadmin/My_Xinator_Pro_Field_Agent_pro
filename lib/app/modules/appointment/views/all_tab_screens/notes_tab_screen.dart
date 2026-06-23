import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/general_text_field.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_buttons.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/text_widget.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/notes/controllers/notes_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/notes/models/note_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/light_theme_colors.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';

class NotesTabScreen extends StatefulWidget {
  const NotesTabScreen({super.key});

  @override
  State<NotesTabScreen> createState() => _NotesTabScreenState();
}

class _NotesTabScreenState extends State<NotesTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  late final NotesController notesController;

  @override
  void initState() {
    super.initState();
    notesController = Get.find<NotesController>();

    final appointment = controller.selectedAppointment.value;
    if (appointment != null) {
      notesController.fetchNotes(
        customerId: appointment.customerID?.toString() ?? '',
        siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
        companyId: appointment.companyID,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text('Notes', style: WarmOrganicBlueTheme.headingMedium),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: OrganicPrimaryButton(
                text: 'Add Notes',
                icon: Icons.add_photo_alternate_rounded,
                height: 42.h,
                onPressed: () {
                  showAccNotesDialog(
                    context,
                    notesController,
                    controller,
                    theme,
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),

            Expanded(
              child: Obx(() {
                final notes = notesController.notes;

                if (notes.isEmpty) {
                  return Center(child: TextWidget(text: "No Notes Found"));
                }

                return ListView.separated(
                  padding: EdgeInsets.only(bottom: 80.h),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final createdAt =
                        DateTime.tryParse(note.createdAt) ?? DateTime.now();
                    final reference = note.reference ?? 'No reference';
                    final userId = note.userId ?? 'Unknown';

                    return OrganicCard(
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        "MMMM dd, yyyy HH:mm",
                                      ).format(createdAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                          ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'User: $userId',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 11.sp,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Ref: $reference',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 11.sp,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => showUpdateNoteDialog(
                                      context,
                                      notesController,
                                      controller,
                                      note,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.blue.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 12.sp,
                                            color: Colors.blue[700],
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  InkWell(
                                    onTap: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete Note'),
                                          content: const Text(
                                            'Are you sure you want to delete this note?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        final appointment = controller
                                            .selectedAppointment
                                            .value;
                                        if (appointment != null) {
                                          await notesController.deleteNote(
                                            noteId: note.id,
                                            customerId:
                                                appointment.customerID
                                                    ?.toString() ??
                                                '',
                                            siteId:
                                                int.tryParse(
                                                  appointment.siteID ?? '',
                                                ) ??
                                                0,
                                            companyId: appointment.companyID,
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.red.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 14.sp,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          TextWidget(
                            text: note.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

void showUpdateNoteDialog(
  BuildContext context,
  NotesController notesController,
  AppointmentController appointmentController,
  Note note,
) {
  final TextEditingController noteController = TextEditingController(
    text: note.description,
  );
  final TextEditingController referenceController = TextEditingController(
    text: note.reference ?? '',
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Update Note",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: WarmOrganicBlueTheme.deepNavy,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Description",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralTextField(
                    maxLine: 4,
                    minLine: 1,
                    textInputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    hint: "Add a note here..",
                    theme: theme,
                    isEnabled: true,
                    textEditingController: noteController,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Reference (Optional)",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralTextField(
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    hint: "Add reference...",
                    theme: theme,
                    isEnabled: true,
                    textEditingController: referenceController,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: Colors.redAccent,
                          title: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          inactive: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: LightThemeColors.primaryColor,
                          title: "Update",
                          onPressed: () async {
                            if (noteController.text.trim().isEmpty) {
                              MySnackBar.showErrorToast(
                                message: "Please enter a note",
                              );
                              return;
                            }

                            final appointment =
                                appointmentController.selectedAppointment.value;
                            if (appointment == null) {
                              MySnackBar.showErrorToast(
                                message: "No appointment selected",
                              );
                              return;
                            }

                            final success = await notesController.updateNote(
                              noteId: note.id,
                              customerId:
                                  appointment.customerID?.toString() ?? '',
                              siteId:
                                  int.tryParse(appointment.siteID ?? '') ?? 0,
                              description: noteController.text.trim(),
                              reference: referenceController.text.trim().isEmpty
                                  ? null
                                  : referenceController.text.trim(),
                              companyId: appointment.companyID,
                            );

                            if (success) {
                              Navigator.pop(context);
                            }
                          },
                          inactive: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showAccNotesDialog(
  BuildContext context,
  NotesController notesController,
  AppointmentController appointmentController,
  ThemeData theme,
) {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Add Note",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: WarmOrganicBlueTheme.deepNavy,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Description",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralTextField(
                    maxLine: 4,
                    minLine: 1,
                    textInputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    hint: "Add a note here..",
                    theme: theme,
                    isEnabled: true,
                    textEditingController: noteController,
                  ),
                ),
                SizedBox(height: 16.h),
                TextWidget(
                  text: "Reference (Optional)",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WarmOrganicBlueTheme.darkSlate,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GeneralTextField(
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    hint: "Add reference...",
                    theme: theme,
                    isEnabled: true,
                    textEditingController: referenceController,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: Colors.redAccent,
                          title: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          inactive: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: PrimaryButton(
                          backgroundColor: LightThemeColors.primaryColor,
                          title: "Save",
                          onPressed: () async {
                            if (noteController.text.trim().isEmpty) {
                              MySnackBar.showErrorToast(
                                message: "Please enter a note",
                              );
                              return;
                            }

                            final appointment =
                                appointmentController.selectedAppointment.value;
                            if (appointment == null) {
                              MySnackBar.showErrorToast(
                                message: "No appointment selected",
                              );
                              return;
                            }

                            final success = await notesController.createNote(
                              customerId:
                                  appointment.customerID?.toString() ?? '',
                              siteId:
                                  int.tryParse(appointment.siteID ?? '') ?? 0,
                              description: noteController.text.trim(),
                              reference: referenceController.text.trim().isEmpty
                                  ? null
                                  : referenceController.text.trim(),
                              companyId: appointment.companyID,
                            );

                            if (success) {
                              Navigator.pop(context);
                            }
                          },
                          inactive: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

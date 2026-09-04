import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:myxinator_pro_field_agent_pro/app/components/global-widgets/my_snackbar.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/file/controllers/file_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/file/models/file_item_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/app/service/REST/api_urls.dart';
import 'package:myxinator_pro_field_agent_pro/app/service/REST/dio_client.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

class FilesTabScreen extends StatefulWidget {
  const FilesTabScreen({super.key});

  @override
  State<FilesTabScreen> createState() => _FilesTabScreenState();
}

class _FilesTabScreenState extends State<FilesTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  late final FileController fileController;

  @override
  void initState() {
    super.initState();
    fileController = Get.find<FileController>();

    final appointment = controller.selectedAppointment.value;
    if (appointment != null) {
      fileController.fetchFiles(
        customerId: appointment.customerID?.toString() ?? '',
        siteId: int.tryParse(appointment.siteID ?? '') ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmOrganicBlueTheme.warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WarmOrganicBlueTheme.warmGray,
        title: Text('Files', style: WarmOrganicBlueTheme.headingMedium),
        centerTitle: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: OrganicPrimaryButton(
                  text: 'Add Files',
                  icon: Icons.add_photo_alternate_rounded,
                  height: 42.h,
                  onPressed: () => showFileBottomSheet(context, -1),
                ),
              ),

              SizedBox(height: 16.h),

              if (controller.fileUploadList.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Uploads',
                      style: WarmOrganicBlueTheme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                ...controller.fileUploadList
                    .toList()
                    .asMap()
                    .entries
                    .toList()
                    .reversed
                    .map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return OrganicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.time,
                              style: WarmOrganicBlueTheme.bodySmall,
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: item.descriptionController,
                              decoration: InputDecoration(
                                hintText: "Add description...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...item.files.map((file) {
                                    final fileName = file.path.split('/').last;
                                    final extension = fileName.contains('.')
                                        ? fileName.split('.').last.toLowerCase()
                                        : '';
                                    return Container(
                                      height: 120,
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getFileIconData(extension) ??
                                                Icons.insert_drive_file,
                                            size: 40,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Text(
                                              fileName,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  GestureDetector(
                                    onTap: () =>
                                        showFileBottomSheet(context, index),
                                    child: Container(
                                      height: 120,
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            OrganicPrimaryButton(
                              text: "Upload Files",
                              onPressed: () async {
                                final appointment =
                                    controller.selectedAppointment.value;
                                if (appointment == null) {
                                  MySnackBar.showErrorToast(
                                    message: "No appointment selected",
                                  );
                                  return;
                                }

                                final validFiles = <File>[];
                                for (final file in item.files) {
                                  if (!file.existsSync()) {
                                    kLog('File does not exist: ${file.path}');
                                    continue;
                                  }
                                  validFiles.add(file);
                                }

                                if (validFiles.isNotEmpty) {
                                  await fileController.uploadFilesBatch(
                                    customerId:
                                        appointment.customerID?.toString() ??
                                        '',
                                    siteId:
                                        int.tryParse(
                                          appointment.siteID ?? '',
                                        ) ??
                                        0,
                                    files: validFiles,
                                    appointmentId: appointment.apptID
                                        .toString(),
                                    reference:
                                        item
                                            .descriptionController
                                            .text
                                            .isNotEmpty
                                        ? item.descriptionController.text
                                        : item.time.split(" ")[0],
                                    companyId: appointment.companyID,
                                  );
                                }

                                controller.fileUploadList.removeAt(index);
                                await fileController.fetchFiles(
                                  customerId:
                                      appointment.customerID?.toString() ?? '',
                                  siteId:
                                      int.tryParse(appointment.siteID ?? '') ??
                                      0,
                                );
                              },
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      );
                    }),
              ],

              if (fileController.filesGroupedByDate.isNotEmpty) ...[
                SizedBox(height: 16.h),

                ...(fileController.filesGroupedByDate.keys.toList()..sort()).map((
                  date,
                ) {
                  final files = fileController.filesGroupedByDate[date]!;
                  // Get first file to extract reference and user info
                  final firstFile = files.isNotEmpty ? files.first : null;
                  final reference = firstFile?.reference ?? 'N/A';
                  final uploadedBy = firstFile?.uploadedBy ?? 'Unknown';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: WarmOrganicBlueTheme.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'User: $uploadedBy',
                              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Ref: ${reference.isNotEmpty ? reference : 'N/A'}',
                              style: WarmOrganicBlueTheme.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 8.h),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 12.sp, right: 12.sp),
                        child: Row(
                          children: files.map((file) {
                            return GestureDetector(
                              onTap: () => _downloadFile(file),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 100,
                                    margin: EdgeInsets.only(right: 12.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getFileIconData(file.extension) ??
                                              Icons.insert_drive_file,
                                          size: 40,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(height: 5),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            file.fileName,
                                            style: TextStyle(fontSize: 10),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final appointment = controller
                                            .selectedAppointment
                                            .value;
                                        if (appointment == null) {
                                          MySnackBar.showErrorToast(
                                            message: "No appointment selected",
                                          );
                                          return;
                                        }

                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Delete File'),
                                            content: Text(
                                              'Are you sure you want to delete ${file.fileName}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          await fileController.deleteFile(
                                            fileId: file.id,
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
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.9,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 20.w,
                        ),
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                    ],
                  );
                }),
              ],
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(FileItem file) async {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      kLog("Downloading file: ${file.fileName} from ${file.fileUrl}");

      // Use the simple download approach with app's dio instance
      final dio = Dio(); // This should use the same dio instance used for app login
      final fileName = file.fileName;
      final extension = file.extension;

      String finalFileName = fileName;
      if (!fileName.endsWith('.$extension')) {
        finalFileName = '$fileName.$extension';
      }

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$finalFileName';

      await dio.download(file.fileUrl, savePath);

      kLog("File downloaded successfully to: $savePath");

      if (mounted) Navigator.pop(context);

      // Verify file was saved
      final savedFile = File(savePath);
      if (await savedFile.exists()) {
        final fileSize = await savedFile.length();
        MySnackBar.showToast(
          message: 'Downloaded: ${file.fileName} (${(fileSize / 1024).toStringAsFixed(1)} KB)',
        );
        kLog("File saved successfully. Size: $fileSize bytes");
      } else {
        MySnackBar.showErrorToast(message: 'File was not saved properly');
      }
    } catch (e, s) {
      kLog("Download failed: $e");
      kLog("Stack trace: $s");
      if (mounted) Navigator.pop(context);
      MySnackBar.showErrorToast(message: 'Failed to download file: ${e.toString()}');
    }
  }

  bool _isImageFile(String? fileType) {
    if (fileType == null) return false;
    final type = fileType.toLowerCase();
    return type.startsWith('image/');
  }

  IconData? _getFileIconData(String? extension) {
    if (extension == null) return null;
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}

void showFileBottomSheet(BuildContext context, int index) {
  final controller = Get.find<AppointmentController>();

  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.document_scanner),
            title: Text("Pick Document"),
            onTap: () async {
              Navigator.pop(sheetContext);
              final result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
                allowMultiple: true,
              );
              if (result != null &&
                  result.files.isNotEmpty &&
                  context.mounted) {
                final validFiles = await _validateAndFilterFiles(
                  result.files.map((e) => File(e.path!)).toList(),
                  context,
                );
                if (validFiles.isNotEmpty) {
                  if (index != -1) {
                    controller.fileUploadList[index].files.addAll(validFiles);
                  } else {
                    controller.fileUploadList.add(
                      FileUploadItem(
                        time: DateFormat("MM/dd/yyyy").format(DateTime.now()),
                        files: validFiles,
                      ),
                    );
                  }
                  controller.update();
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text("Browse Files"),
            onTap: () async {
              Navigator.pop(sheetContext);
              final result = await FilePicker.pickFiles(
                type: FileType.any,
                allowMultiple: true,
              );
              if (result != null &&
                  result.files.isNotEmpty &&
                  context.mounted) {
                final validFiles = await _validateAndFilterFiles(
                  result.files.map((e) => File(e.path!)).toList(),
                  context,
                );
                if (validFiles.isNotEmpty) {
                  if (index != -1) {
                    controller.fileUploadList[index].files.addAll(validFiles);
                  } else {
                    controller.fileUploadList.add(
                      FileUploadItem(
                        time: DateFormat("MM/dd/yyyy").format(DateTime.now()),
                        files: validFiles,
                      ),
                    );
                  }
                  controller.update();
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<List<File>> _validateAndFilterFiles(
  List<File> files,
  BuildContext context,
) async {
  const maxSizeInBytes = 10 * 1024 * 1024;
  final validFiles = <File>[];
  final skippedFiles = <String>[];

  for (var file in files) {
    try {
      final fileSize = await file.length();
      if (fileSize <= maxSizeInBytes) {
        validFiles.add(file);
      } else {
        final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        skippedFiles.add('${file.uri.pathSegments.last} ($sizeInMB MB)');
      }
    } catch (e) {
      skippedFiles.add('${file.uri.pathSegments.last} (Error: $e)');
    }
  }

  if (skippedFiles.isNotEmpty && context.mounted) {
    MySnackBar.showErrorToast(
      message:
          'Skipped ${skippedFiles.length} file(s) over 10MB limit:\n${skippedFiles.take(3).join("\n")}${skippedFiles.length > 3 ? "\n..." : ""}',
    );
  }

  return validFiles;
}

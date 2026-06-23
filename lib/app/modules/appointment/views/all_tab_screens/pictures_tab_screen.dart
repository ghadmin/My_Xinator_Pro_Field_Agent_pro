import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/controllers/appointment_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/parts/image/controllers/image_controller.dart';
import 'package:myxinator_pro_field_agent_pro/app/modules/appointment/views/widgets/warm_organic_components.dart';
import 'package:myxinator_pro_field_agent_pro/config/theme/warm_organic_blue_theme.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

class PicturesTabScreen extends StatefulWidget {
  const PicturesTabScreen({super.key});

  @override
  State<PicturesTabScreen> createState() => _PicturesTabScreenState();
}

class _PicturesTabScreenState extends State<PicturesTabScreen> {
  final AppointmentController controller = Get.find<AppointmentController>();
  late final ImageController imageController;

  @override
  void initState() {
    super.initState();
    imageController = Get.find<ImageController>();

    final appointment = controller.selectedAppointment.value;
    if (appointment != null) {
      imageController.fetchPictures(
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
        title: Text('Pictures', style: WarmOrganicBlueTheme.headingMedium),
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
                  text: 'Add Photo',
                  icon: Icons.add_photo_alternate_rounded,
                  height: 42.h,
                  onPressed: () => _showMediaOptions(context),
                ),
              ),
              SizedBox(height: 16.h),

              if (controller.mediaList.isNotEmpty) ...[
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
                ...controller.mediaList
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
                                  ...item.images.map((e) {
                                    if (_isVideo(e)) {
                                      return GestureDetector(
                                        onTap: () =>
                                            showMediaDialog(context, e),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: FutureBuilder<String?>(
                                            future: generateVideoThumbnail(e),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      height: 150,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                        image: DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: FileImage(
                                                            File(
                                                              snapshot.data!,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Positioned.fill(
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .play_circle_fill,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return Container(
                                                height: 150,
                                                width: 150,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.play_circle_fill,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () =>
                                            showMediaDialog(context, e),
                                        child: Container(
                                          height: 150,
                                          width: 150,
                                          margin: EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: FileImage(File(e)),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                  GestureDetector(
                                    onTap: () =>
                                        showMediaBottomSheet(context, index),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          10.r,
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
                              text: "Upload Images",
                              onPressed: () async {
                                final appointment =
                                    controller.selectedAppointment.value;
                                if (appointment == null) {
                                  Get.snackbar(
                                    "Error",
                                    "No appointment selected",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                final files = <File>[];
                                for (final imagePath
                                    in controller.mediaList.first.images) {
                                  final file = File(imagePath);
                                  if (!file.existsSync()) {
                                    kLog(
                                      'Image file does not exist: $imagePath',
                                    );
                                    continue;
                                  }
                                  files.add(file);
                                }

                                if (files.isNotEmpty) {
                                  await imageController.uploadPicturesBatch(
                                    customerId:
                                        appointment.customerID?.toString() ??
                                        '',
                                    siteId:
                                        int.tryParse(
                                          appointment.siteID ?? '',
                                        ) ??
                                        0,
                                    files: files,
                                    appointmentId: appointment.apptID
                                        .toString(),
                                    reference:
                                        item
                                            .descriptionController
                                            .text
                                            .isNotEmpty
                                        ? item.descriptionController.text
                                        : item.time.split(" ")[0],
                                  );
                                }

                                controller.mediaList.clear();
                                await imageController.fetchPictures(
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

              if (imageController.picturesGroupedByDate.isNotEmpty) ...[
                SizedBox(height: 16.h),
                ...(imageController.picturesGroupedByDate.keys.toList()..sort()).map((
                  date,
                ) {
                  final images = imageController.picturesGroupedByDate[date]!;
                  // Get first image to extract reference and user info
                  final firstImage = images.isNotEmpty ? images.first : null;
                  final reference = firstImage?.reference ?? 'No reference';
                  final uploadedBy = firstImage?.uploadedBy ?? 'Unknown';

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
                              'Ref: $reference',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: images.map((item) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => _NetworkImageDialog(
                                    imageUrl: item.fileUrl,
                                    pictureId: item.id.toString(),
                                    onDelete: () async {
                                      final appointment =
                                          controller.selectedAppointment.value;
                                      if (appointment == null) {
                                        Get.snackbar(
                                          'Error',
                                          'No appointment selected',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return false;
                                      }

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete Picture'),
                                          content: const Text(
                                            'Are you sure you want to delete this picture?',
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
                                        await imageController.deletePicture(
                                          pictureId: item.id,
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
                                        return true;
                                      }
                                      return false;
                                    },
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 150,
                                    width: 150,
                                    margin: EdgeInsets.only(right: 12.sp),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: CachedNetworkImage(
                                        imageUrl: item.fileUrl,
                                        fit: BoxFit.fill,
                                        placeholder: (_, __) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
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
                                          Get.snackbar(
                                            'Error',
                                            'No appointment selected',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }

                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Delete Picture'),
                                            content: const Text(
                                              'Are you sure you want to delete this picture?',
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
                                          await imageController.deletePicture(
                                            pictureId: item.id,
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

  void _showMediaOptions(BuildContext context) {
    showMediaBottomSheet(context, -1);
  }

  bool _isVideo(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }
}

void showMediaDialog(BuildContext context, String path) {
  if (path.split('.').last.toLowerCase() == 'mp4' ||
      path.split('.').last.toLowerCase() == 'mov' ||
      path.split('.').last.toLowerCase() == 'avi' ||
      path.split('.').last.toLowerCase() == 'mkv') {
    showDialog(
      context: context,
      builder: (_) => _VideoDialog(videoPath: path),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => _ImageDialog(imagePath: path),
    );
  }
}

class _ImageDialog extends StatefulWidget {
  final String imagePath;
  const _ImageDialog({required this.imagePath});

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Image Viewer with Zoom and Pan
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 8.0,
              child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),

          // Top Bar - Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageDialog extends StatefulWidget {
  final String imageUrl;
  final String pictureId;
  final Future<bool> Function() onDelete;

  const _NetworkImageDialog({
    required this.imageUrl,
    required this.pictureId,
    required this.onDelete,
  });

  @override
  State<_NetworkImageDialog> createState() => _NetworkImageDialogState();
}

class _NetworkImageDialogState extends State<_NetworkImageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Image Viewer with Zoom and Pan
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 8.0,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error, color: Colors.white)),
              ),
            ),
          ),

          // Top Left - Delete button
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final shouldClose = await widget.onDelete();
                if (shouldClose && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),

          // Top Right - Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoDialog extends StatefulWidget {
  final String videoPath;
  const _VideoDialog({required this.videoPath});

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            )
          : SizedBox(
              height: 150,
              width: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

Future<String?> generateVideoThumbnail(String videoPath) async {
  final tempDir = await getTemporaryDirectory();
  return await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: tempDir.path,
    imageFormat: ImageFormat.PNG,
    maxWidth: 150,
    quality: 75,
  );
}

void showMediaBottomSheet(BuildContext context, int index) {
  final appointmentC = Get.find<AppointmentController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: 100.h,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MediaButton(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () async {
                      try {
                        final List<XFile?> files = await ImagePicker()
                            .pickMultiImage();
                        if (files.isNotEmpty) {
                          final newImages = <String>[];
                          for (var file in files) {
                            if (file != null) {
                              final compressedPath = await compressImage(
                                file.path,
                              );
                              newImages.add(compressedPath);
                            }
                          }

                          if (newImages.isNotEmpty) {
                            if (index != -1) {
                              appointmentC.mediaList[index].images.addAll(
                                newImages,
                              );
                            } else {
                              appointmentC.mediaList.add(
                                MediaModel(
                                  time: DateFormat(
                                    "MM/dd/yyyy",
                                  ).format(DateTime.now()),
                                  images: newImages,
                                ),
                              );
                            }
                          }
                        }

                        appointmentC.update();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error picking images: Unable to access gallery. Please check permissions.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }

                      Navigator.pop(context);
                    },
                  ),
                  _MediaButton(
                    icon: Icons.camera_alt,
                    title: 'Photo',
                    onTap: () async {
                      try {
                        final XFile? file = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          imageQuality: 85,
                        );
                        if (file != null) {
                          final compressedPath = await compressImage(file.path);

                          if (index != -1) {
                            appointmentC.mediaList[index].images.add(
                              compressedPath,
                            );
                            appointmentC.mediaList.refresh();
                          } else {
                            appointmentC.mediaList.add(
                              MediaModel(
                                time: DateFormat(
                                  "MM/dd/yyyy",
                                ).format(DateTime.now()),
                                images: [compressedPath],
                              ),
                            );
                          }
                        }

                        appointmentC.update();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error taking photo: Unable to access camera. Please check permissions.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

Future<String> compressImage(String filePath) async {
  final compressedFile = await FlutterImageCompress.compressWithFile(
    filePath,
    quality: 40,
    minWidth: 800,
    minHeight: 800,
    format: CompressFormat.jpeg,
  );

  if (compressedFile == null) return filePath;

  final tempDir = Directory.systemTemp;
  final tempFile = await File(
    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
  ).writeAsBytes(compressedFile);

  return tempFile.path;
}

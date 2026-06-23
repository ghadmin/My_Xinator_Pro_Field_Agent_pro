import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/rag_service.dart';
import '../../../../utils/klog.dart';
import '../../appointment/controllers/appointment_controller.dart';

class RAGController extends GetxController {
  final RAGService _ragService = RAGService();

  final RxBool isLoading = false.obs;
  final RxString answer = ''.obs;
  final RxList<RAGSource> sources = <RAGSource>[].obs;
  final RxDouble confidence = 0.0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt indexedCount = 0.obs;
  final RxBool isSyncing = false.obs;

  final questionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    syncAppointmentsFirst(); // Call syncAppointments first
    loadStats();
  }

  /// Sync appointments first when RAG controller initializes
  Future<void> syncAppointmentsFirst() async {
    try {
      if (!Get.isRegistered<AppointmentController>()) {
        kLog('AppointmentController not registered, skipping sync');
        return;
      }

      final appointmentController = Get.find<AppointmentController>();

      isSyncing.value = true;
      kLog('Fetching appointments from server...');

      // Call getAppointments to get fresh data from server
      await appointmentController.getAppointments(showLoader: false);

      if (appointmentController.appointments.isEmpty) {
        kLog('No appointments to sync to RAG');
        return;
      }

      kLog('Syncing ${appointmentController.appointments.length} appointments to RAG system...');

      // Convert appointments to JSON format
      final appointmentsData = appointmentController.appointments
          .map((apt) => apt.toJson())
          .toList();

      final success = await _ragService.syncAppointments(appointmentsData);

      if (success) {
        kLog('Successfully synced ${appointmentsData.length} appointments to RAG');
      } else {
        kLog('Failed to sync appointments to RAG');
      }
    } catch (e) {
      kLog('Error syncing appointments to RAG: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }

  Future<void> loadStats() async {
    final stats = await _ragService.getStats();
    if (stats != null) {
      indexedCount.value = stats['total_appointments'] ?? 0;
      kLog('RAG stats loaded: $indexedCount appointments indexed');
    }
  }

  Future<void> askQuestion() async {
    final question = questionController.text.trim();
    if (question.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a question',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    answer.value = '';
    sources.clear();
    confidence.value = 0.0;

    final response = await _ragService.queryAppointments(question);

    isLoading.value = false;

    if (response != null) {
      answer.value = response.answer;
      sources.assignAll(response.sources);
      confidence.value = response.confidence ?? 0.0;
      kLog('Question answered with ${response.sources.length} sources');
    } else {
      hasError.value = true;
      errorMessage.value = 'Failed to get response from RAG service';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<String> getSuggestedQuestions() {
    return [
      'What appointments do I have today?',
      'Show me appointments for customer John Doe',
      'What maintenance appointments are scheduled?',
      'Do I have any appointments this week?',
      'Which appointments need equipment preparation?',
    ];
  }

  void clearResults() {
    answer.value = '';
    sources.clear();
    confidence.value = 0.0;
    hasError.value = false;
    errorMessage.value = '';
  }
}

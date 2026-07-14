import 'package:get/get.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/signature/signature_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/models/signature/signature_request_model.dart';
import 'package:myxinator_pro_field_agent_pro/app/repositories/signature_repository.dart';
import 'package:myxinator_pro_field_agent_pro/app/services/signature_api_service.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

/// Signature Provider
///
/// Manages signature state with GetX
class SignatureProvider extends GetxController {
  final SignatureRepository _repository = SignatureRepository();
  final SignatureApiService _apiService = SignatureApiService();

  // ============== OBSERVABLES ==============

  /// Current tab index (0 = Draw, 1 = Type)
  final RxInt currentTabIndex = 0.obs;

  /// Full name input for typed signature
  final RxString fullName = ''.obs;

  /// Selected font for typed signature
  final RxString selectedFont = 'Caveat'.obs;

  /// Base64 data of drawn signature
  final RxString drawnSignatureData = ''.obs;

  /// Generated signature image data (base64)
  final RxString signatureImageData = ''.obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// All saved signatures
  final RxList<SignatureModel> savedSignatures = <SignatureModel>[].obs;

  /// Latest saved signature
  final Rx<SignatureModel?> latestSignature = Rx(null);

  // ============== SIGNATURE FONTS ==============

  /// Available signature fonts
  static const Map<String, String> signatureFonts = {
    'Caveat': 'Caveat',
    'Pacifico': 'Pacifico',
    'Sacramento': 'Sacramento',
    'Satisfy': 'Satisfy',
    'Allura': 'Allura',
    'Tangerine': 'Tangerine',
  };

  /// Get font names as list
  static List<String> get fontNames => signatureFonts.keys.toList();

  /// Get Google Font name from display name
  static String getGoogleFontName(String displayName) {
    return signatureFonts[displayName] ?? displayName;
  }

  // ============== TAB MANAGEMENT ==============

  /// Switch to Draw tab
  void switchToDrawTab() {
    currentTabIndex.value = 0;
  }

  /// Switch to Type tab
  void switchToTypeTab() {
    currentTabIndex.value = 1;
  }

  // ============== TYPE SIGNATURE ==============

  /// Update full name for typed signature
  void updateFullName(String value) {
    fullName.value = value;
    // Clear error when user starts typing
    if (value.isNotEmpty && errorMessage.value == 'Please enter your full name') {
      errorMessage.value = '';
    }
  }

  /// Select a font for typed signature
  void selectFont(String fontName) {
    selectedFont.value = fontName;
    kLog('Font selected: $fontName');
  }

  /// Validate typed signature
  bool validateTypedSignature() {
    if (fullName.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return false;
    }
    return true;
  }

  // ============== DRAW SIGNATURE ==============

  /// Update drawn signature data
  void updateDrawnSignature(String base64Data) {
    drawnSignatureData.value = base64Data;
    kLog('Drawn signature updated');
  }

  /// Clear drawn signature
  void clearDrawnSignature() {
    drawnSignatureData.value = '';
    kLog('Drawn signature cleared');
  }

  /// Validate drawn signature
  bool validateDrawnSignature() {
    if (drawnSignatureData.value.isEmpty) {
      errorMessage.value = 'Please draw your signature';
      return false;
    }
    return true;
  }

  // ============== SAVE SIGNATURE ==============

  /// Save current signature
  Future<bool> saveSignature() async {
    try {
      // Validate based on current tab
      if (currentTabIndex.value == 0) {
        // Draw tab
        if (!validateDrawnSignature()) return false;
      } else {
        // Type tab
        if (!validateTypedSignature()) return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Generate signature ID using timestamp and random
      final signatureId = 'sig_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

      // Create signature model
      final signature = SignatureModel(
        id: signatureId,
        fullName: currentTabIndex.value == 1 ? fullName.value.trim() : '',
        fontName: currentTabIndex.value == 1 ? selectedFont.value : null,
        signatureImageData: currentTabIndex.value == 0
            ? drawnSignatureData.value
            : signatureImageData.value,
        type: currentTabIndex.value == 0
            ? SignatureType.drawn
            : SignatureType.typed,
        createdAt: DateTime.now(),
      );

      // Save to repository
      final success = await _repository.saveSignature(signature);

      if (success) {
        // Update latest signature
        latestSignature.value = signature;

        // Reload saved signatures
        await loadSavedSignatures();

        kLog('✅ Signature saved successfully: $signatureId');
        return true;
      } else {
        errorMessage.value = 'Failed to save signature';
        return false;
      }
    } catch (e) {
      kLog('❌ Error saving signature: $e');
      errorMessage.value = 'Error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============== LOAD SIGNATURES ==============

  /// Load all saved signatures
  Future<void> loadSavedSignatures() async {
    try {
      isLoading.value = true;
      final signatures = await _repository.getAllSignatures();
      savedSignatures.assignAll(signatures);

      // Update latest signature
      if (signatures.isNotEmpty) {
        latestSignature.value = signatures.first;
      }

      kLog('✅ Loaded ${signatures.length} signatures');
    } catch (e) {
      kLog('❌ Error loading signatures: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load latest signature
  Future<void> loadLatestSignature() async {
    try {
      isLoading.value = true;
      final signature = await _repository.getLatestSignature();
      latestSignature.value = signature;
    } catch (e) {
      kLog('❌ Error loading latest signature: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============== DELETE SIGNATURE ==============

  /// Delete a signature
  Future<bool> deleteSignature(String id) async {
    try {
      isLoading.value = true;
      final success = await _repository.deleteSignature(id);

      if (success) {
        // Reload signatures
        await loadSavedSignatures();
        kLog('✅ Signature deleted: $id');
        return true;
      }
      return false;
    } catch (e) {
      kLog('❌ Error deleting signature: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============== CLEAR ALL ==============

  /// Clear all data
  void clearAll() {
    currentTabIndex.value = 0;
    fullName.value = '';
    selectedFont.value = 'Caveat';
    drawnSignatureData.value = '';
    signatureImageData.value = '';
    errorMessage.value = '';
  }

  // ============== SIGNATURE TO IMAGE ==============

  /// Set signature image data (for typed signatures converted to image)
  void setSignatureImageData(String base64Data) {
    signatureImageData.value = base64Data;
  }

  // ============== SIGNATURE API METHODS ==============

  /// Save signature for payment
  ///
  /// Saves current signature for a specific payment using the new signature model structure
  /// [paymentId] - The payment ID to attach the signature to
  /// [customerId] - Customer ID (optional)
  /// [companyId] - Company ID (optional)
  /// [userId] - User ID (optional)
  /// [appointmentId] - Appointment ID (optional)
  /// [invoiceId] - Invoice ID (optional)
  Future<bool> saveSignatureForPayment({
    required int paymentId,
    int? customerId,
    String? companyId,
    String? userId,
    int? appointmentId,
    String? invoiceId,
  }) async {
    try {
      // Validate based on current tab
      if (currentTabIndex.value == 0) {
        // Draw tab
        if (!validateDrawnSignature()) return false;
      } else {
        // Type tab
        if (!validateTypedSignature()) return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Get signature data
      final signatureData = currentTabIndex.value == 0
          ? drawnSignatureData.value
          : signatureImageData.value;

      // Generate signature filename
      final signatureType = currentTabIndex.value == 0 ? 'drawn' : 'typed';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signatureFileName = 'signature_${signatureType}_$timestamp.png';

      // Create signature request model
      final request = SignatureRequestModel.forPayment(
        paymentId: paymentId,
        signatureFileName: signatureFileName,
        signatureFileContent: signatureData,
        customerId: customerId,
        companyId: companyId,
        userId: userId,
        appointmentId: appointmentId,
        invoiceId: invoiceId,
      );

      // Call API service
      final response = await _apiService.saveSignatureForPayment(
        request: request,
      );

      if (_apiService.isSuccess(response)) {
        kLog('✅ Signature saved for payment: $paymentId');
        return true;
      } else {
        final errorMsg = _apiService.getErrorMessage(response);
        errorMessage.value = errorMsg;
        kLog('❌ Failed to save signature for payment: $errorMsg');
        return false;
      }
    } catch (e) {
      kLog('❌ Error saving signature for payment: $e');
      errorMessage.value = 'Error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Save signature for appointment
  ///
  /// Saves current signature for a specific appointment using the new signature model structure
  /// [appointmentId] - The appointment ID to attach the signature to
  /// [customerId] - Customer ID (optional)
  /// [companyId] - Company ID (optional)
  /// [userId] - User ID (optional)
  Future<bool> saveSignatureForAppointment({
    required String appointmentId,
    int? customerId,
    String? companyId,
    String? userId,
  }) async {
    try {
      // Validate based on current tab
      if (currentTabIndex.value == 0) {
        // Draw tab
        if (!validateDrawnSignature()) return false;
      } else {
        // Type tab
        if (!validateTypedSignature()) return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Get signature data
      final signatureData = currentTabIndex.value == 0
          ? drawnSignatureData.value
          : signatureImageData.value;

      // Generate signature filename
      final signatureType = currentTabIndex.value == 0 ? 'drawn' : 'typed';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signatureFileName = 'signature_${signatureType}_$timestamp.png';

      // Create signature request model
      final request = SignatureRequestModel.forAppointment(
        appointmentId: int.parse(appointmentId),
        signatureFileName: signatureFileName,
        signatureFileContent: signatureData,
        customerId: customerId,
        companyId: companyId,
        userId: userId,
      );

      // Call API service
      final response = await _apiService.saveSignature(
        request: request,
      );

      if (_apiService.isSuccess(response)) {
        kLog('✅ Signature saved for appointment: $appointmentId');
        return true;
      } else {
        final errorMsg = _apiService.getErrorMessage(response);
        errorMessage.value = errorMsg;
        kLog('❌ Failed to save signature for appointment: $errorMsg');
        return false;
      }
    } catch (e) {
      kLog('❌ Error saving signature for appointment: $e');
      errorMessage.value = 'Error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadSavedSignatures();
  }

  @override
  void onClose() {
    clearAll();
    super.onClose();
  }
}

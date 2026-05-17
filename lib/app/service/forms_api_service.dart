import 'dart:developer';
import 'dart:typed_data';

import 'package:myxinator_pro_field_agent_pro/app/service/REST/api_urls.dart';

import '../models/forms/forms_models.dart';
import 'REST/dio_client.dart';

/// Forms API Service
///
/// Handles all FaProSync Forms API calls
class FormsApiService {
  final DioClient _dioClient = DioClient();

  /// Poll for pending forms
  ///
  /// GET /FaProSync.ashx?op=poll&companyId={X}&resourceId={Y}
  Future<FormsPollResponse?> pollForms({
    required String companyId,
    required String resourceId,
  }) async {
    try {
      log('📋 Polling forms: companyId=$companyId, resourceId=$resourceId');

      final response = await _dioClient.get(
        url: ApiUrl.pollUrl(companyId, resourceId),
        headers: ApiUrl.authHeaders,
      );

      if (response == null) {
        log('⚠️ Poll response is null');
        return null;
      }

      log('✅ Poll response: count=${response['count'] ?? 0}');
      return FormsPollResponse.fromJson(response);
    } catch (e) {
      log('❌ Poll error: $e');
      rethrow;
    }
  }

  /// Acknowledge downloaded forms
  ///
  /// POST /FaProSync.ashx?op=ack
  Future<AckResponse?> ackForms({
    required String companyId,
    required List<int> queueIds,
    String? deviceInfo,
  }) async {
    try {
      log('📬 Acknowledging forms: ${queueIds.length} items');

      final request = AckRequest(
        companyId: companyId,
        queueIds: queueIds,
        deviceInfo: deviceInfo,
      );

      final response = await _dioClient.post(
        url: ApiUrl.ackUrl,
        body: request.toJson(),
        headers: ApiUrl.authHeaders,
      );

      if (response == null) {
        log('⚠️ Ack response is null');
        return null;
      }

      log('✅ Ack response: ${response['acked']?.length ?? 0} acknowledged');
      return AckResponse.fromJson(response);
    } catch (e) {
      log('❌ Ack error: $e');
      rethrow;
    }
  }

  /// Submit a completed form
  ///
  /// POST /FaProSync.ashx?op=submit
  Future<SubmitResponse?> submitForm({
    required String companyId,
    required int formInstanceId,
    int? queueId,
    required int templateId,
    required String appointmentId,
    String? customerId,
    String? deviceInfo,
    required List<FieldResponse> responses,
  }) async {
    try {
      log(
        '📤 Submitting form: instanceId=$formInstanceId, templateId=$templateId',
      );

      final request = SubmitRequest(
        companyId: companyId,
        formInstanceId: formInstanceId,
        queueId: queueId,
        templateId: templateId,
        appointmentId: appointmentId,
        customerId: customerId,
        deviceInfo: deviceInfo,
        responses: responses,
      );

      final response = await _dioClient.post(
        url: ApiUrl.submitUrl,
        body: request.toJson(),
        headers: ApiUrl.authHeaders,
      );

      if (response == null) {
        log('⚠️ Submit response is null');
        return null;
      }

      final submitResponse = SubmitResponse.fromJson(response);
      log(
        '✅ Submit response: responseId=${submitResponse.formResponseId}, '
        'stamped=${submitResponse.stampedPdfUrl != null}',
      );

      return submitResponse;
    } catch (e) {
      log('❌ Submit error: $e');
      rethrow;
    }
  }

  /// Download a PDF file
  ///
  /// [savePath] is the full path where the PDF should be saved
  Future<bool> downloadPdf({
    required String relativePath,
    required String savePath,
  }) async {
    try {
      log('📄 Downloading PDF: $relativePath to $savePath');

      final result = await _dioClient.download(
        url: ApiUrl.pdfDownloadUrl(relativePath),
        savePath: savePath,
        headers: ApiUrl.authHeaders,
      );

      if (result != null) {
        log('✅ PDF downloaded successfully');
        return true;
      }

      log('⚠️ PDF download failed');
      return false;
    } catch (e) {
      log('❌ PDF download error: $e');
      rethrow;
    }
  }

  /// Get the full URL for viewing a stamped PDF
  String getStampedPdfUrl(String relativePath) {
    return ApiUrl.stampedPdfUrl(relativePath);
  }

  /// Get form template JSON for dynamic form rendering
  ///
  /// GET /FaProSync.ashx?op=gettemplate&companyId={X}&templateId={Y}
  Future<Map<String, dynamic>?> getFormTemplate({
    required String companyId,
    required int templateId,
  }) async {
    try {
      log(
        '📋 Getting form template: companyId=$companyId, templateId=$templateId',
      );

      final response = await _dioClient.get(
        url: ApiUrl.getTemplateUrl(companyId, templateId),
        headers: ApiUrl.authHeaders,
      );
      log('📋 Getting form template response : $response');

      if (response == null) {
        log('⚠️ Template response is null');
        return null;
      }

      log('✅ Template loaded successfully');
      return response;
    } catch (e) {
      log('❌ Get template error: $e');
      rethrow;
    }
  }

  /// Get PDF bytes for form rendering
  ///
  /// Downloads the PDF file and returns as Uint8List
  Future<Uint8List?> getFormPdfBytes({
    required String companyId,
    required int templateId,
  }) async {
    try {
      log('📄 Getting PDF bytes: companyId=$companyId, templateId=$templateId');

      final response = await _dioClient.downloadBytes(
        url: ApiUrl.getTemplatePdfUrl(companyId, templateId),
        headers: ApiUrl.authHeaders,
      );

      if (response != null) {
        log('✅ PDF bytes loaded: ${response.length} bytes');
        return response;
      }

      log('⚠️ PDF bytes response is null');
      return null;
    } catch (e) {
      log('❌ Get PDF bytes error: $e');
      return null;
    }
  }

  /// Fetch PDF bytes from a direct URL
  ///
  /// Downloads PDF from any URL (useful for pre-signed URLs or direct paths)
  Future<Uint8List?> fetchPdfBytes(String pdfUrl) async {
    try {
      log('📄 Fetching PDF bytes from URL: $pdfUrl');

      final response = await _dioClient.downloadBytes(
        url: pdfUrl,
        headers: ApiUrl.authHeaders,
      );

      if (response != null) {
        log('✅ PDF bytes fetched: ${response.length} bytes');
        return response;
      }

      log('⚠️ PDF bytes response is null');
      return null;
    } catch (e) {
      log('❌ Fetch PDF bytes error: $e');
      return null;
    }
  }
}

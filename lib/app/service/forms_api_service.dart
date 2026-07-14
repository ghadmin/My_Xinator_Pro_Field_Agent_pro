import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:myxinator_pro_field_agent_pro/app/service/REST/api_urls.dart';
import 'package:myxinator_pro_field_agent_pro/utils/klog.dart';

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
      kLog('📋 Poll response: ${jsonEncode(response)}');
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

  /// Get form response by ID
  ///
  /// GET /FaProSync.ashx?op=getResponse&companyId={X}&formResponseId={Y}
  Future<Map<String, dynamic>?> getResponse({
    required String companyId,
    required int formResponseId,
  }) async {
    try {
      log(
        '📋 Getting form response: companyId=$companyId, formResponseId=$formResponseId',
      );

      final response = await _dioClient.get(
        url: ApiUrl.getResponseUrl(companyId, formResponseId),
        headers: ApiUrl.authHeaders,
      );

      if (response == null) {
        log('⚠️ Get response returned null');
        return null;
      }

      log('✅ Form response loaded successfully');
      return response;
    } catch (e) {
      log('❌ Get response error: $e');
      rethrow;
    }
  }

  /// Get form response by natural key (templateId + appointmentId + customerId)
  ///
  /// GET /FaProSync.ashx?op=getResponse&companyId={X}&templateId={Y}&appointmentId={Z}&customerId={W}
  Future<Map<String, dynamic>?> getResponseByNaturalKey({
    required String companyId,
    required int templateId,
    required String appointmentId,
    required String customerId,
  }) async {
    try {
      log(
        '📋 Getting form response by natural key: companyId=$companyId, templateId=$templateId, appointmentId=$appointmentId, customerId=$customerId',
      );

      final response = await _dioClient.get(
        url: ApiUrl.getResponseByNaturalKeyUrl(
          companyId: companyId,
          templateId: templateId,
          appointmentId: appointmentId,
          customerId: customerId,
        ),
        headers: ApiUrl.authHeaders,
      );

      if (response == null) {
        log('⚠️ Get response by natural key returned null');
        return null;
      }

      log('✅ Form response loaded successfully');
      return response;
    } catch (e) {
      log('❌ Get response by natural key error: $e');
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

  // ============== FaProMobile API METHODS ==============

  /// List files for a customer/site using FaProMobile API
  ///
  /// GET ?resource=files&op=list&customerId={id}&siteId={id}
  Future<Map<String, dynamic>?> listFiles({
    required String companyId,
    required String customerId,
    required String siteId,
  }) async {
    try {
      log(
        '📄 Listing files: companyId=$companyId, customerId=$customerId, siteId=$siteId',
      );

      final url = ApiUrl.buildFaProMobileUrl(
        resource: 'files',
        operation: 'list',
        companyId: companyId,
        extraParams: {'customerId': customerId, 'siteId': siteId},
      );

      final response = await _dioClient.get(
        url: url,
        headers: ApiUrl.faProMobileAuthHeaders,
      );

      if (response != null) {
        log('✅ Files list response: ${response['count'] ?? 0} items');
        return response;
      }

      log('⚠️ Files list response is null');
      return null;
    } catch (e) {
      log('❌ List files error: $e');
      return null;
    }
  }

  /// Download file bytes from FaProMobile API
  ///
  /// Note: As per API docs, a sessionless download endpoint is planned
  /// but not yet available. This method attempts to fetch from the fileUrl
  /// returned by the list endpoint, which may require authentication.
  Future<Uint8List?> downloadFileBytes({
    required String companyId,
    required int fileId,
    required String fileUrl,
  }) async {
    try {
      log('📄 Downloading file: fileId=$fileId, url=$fileUrl');

      // Try the fileUrl from the list response
      // Note: This may fail due to session authentication requirements
      final response = await _dioClient.downloadBytes(
        url: fileUrl,
        headers: ApiUrl.faProMobileAuthHeaders,
      );

      if (response != null) {
        log('✅ File bytes downloaded: ${response.length} bytes');
        return response;
      }

      log('⚠️ File bytes response is null');
      return null;
    } catch (e) {
      log('❌ Download file error: $e');
      return null;
    }
  }

  /// Find and download a PDF file by filename
  ///
  /// Combines list + download to find a specific PDF and return its bytes
  Future<Uint8List?> findAndDownloadPdf({
    required String companyId,
    required String customerId,
    required String siteId,
    required String fileName,
  }) async {
    try {
      // Step 1: List files to find the PDF ID
      final listResponse = await listFiles(
        companyId: companyId,
        customerId: customerId,
        siteId: siteId,
      );

      if (listResponse == null || !listResponse['success']) {
        log('⚠️ Failed to list files');
        return null;
      }

      final items = listResponse['items'] as List?;
      if (items == null || items.isEmpty) {
        log('⚠️ No files found');
        return null;
      }

      // Step 2: Find the PDF by filename (case-insensitive partial match)
      Map<String, dynamic>? targetFile;
      for (final item in items) {
        final file = item as Map<String, dynamic>;
        final currentFileName = file['fileName'] as String? ?? '';
        if (currentFileName.toLowerCase().contains(fileName.toLowerCase())) {
          targetFile = file;
          break;
        }
      }

      if (targetFile == null) {
        log('⚠️ PDF not found: $fileName');
        return null;
      }

      final fileId = targetFile['id'] as int?;
      final fileUrl = targetFile['fileUrl'] as String?;

      if (fileId == null || fileUrl == null || fileUrl.isEmpty) {
        log('⚠️ Invalid file data: id=$fileId, url=$fileUrl');
        return null;
      }

      log('📄 Found PDF: id=$fileId, fileName=${targetFile['fileName']}');

      // Step 3: Download the file bytes
      return await downloadFileBytes(
        companyId: companyId,
        fileId: fileId,
        fileUrl: fileUrl,
      );
    } catch (e) {
      log('❌ Find and download PDF error: $e');
      return null;
    }
  }

  /// Send PDF via email to customer
  ///
  /// POST /fsm/FaProSync.ashx?op=emailPdf
  Future<Map<String, dynamic>?> sendPdfEmail({
    required String companyId,
    int? formResponseId,
    int? templateId,
    String? appointmentId,
    String? customerId,
    String? toEmail,
  }) async {
    try {
      log(
        '📧 Sending PDF email: companyId=$companyId, formResponseId=$formResponseId, templateId=$templateId, appointmentId=$appointmentId',
      );

      // Build request body - prefer formResponseId (Shape A), fall back to natural key (Shape B)
      final body = <String, dynamic>{'companyId': companyId};

      if (formResponseId != null && formResponseId > 0) {
        // Shape A - preferred when you have the formResponseId from submit
        body['formResponseId'] = formResponseId;
      } else if (templateId != null &&
          appointmentId != null &&
          customerId != null) {
        // Shape B - natural key; resolves the latest matching FormResponse
        body['templateId'] = templateId;
        body['appointmentId'] = appointmentId;
        body['customerId'] = customerId;
      } else {
        log(
          '⚠️ Invalid emailPdf request: missing formResponseId or natural key',
        );
        return null;
      }

      // Optional email override
      if (toEmail != null && toEmail.isNotEmpty) {
        body['to'] = toEmail;
      }

      final response = await _dioClient.post(
        url: '${ApiUrl.currentBaseUrl}/FaProSync.ashx?op=emailPdf',
        body: body,
        headers: ApiUrl.authHeaders,
      );

      if (response != null) {
        if (response['success'] == true) {
          log(
            '✅ PDF email sent successfully: to=${response['toEmail']}, status=${response['emailStatus']}',
          );
        } else {
          log(
            '⚠️ PDF email failed: ${response['emailError'] ?? response['error']}',
          );
        }
        return response;
      }

      log('⚠️ PDF email response is null');
      return null;
    } catch (e) {
      log('❌ Send PDF email error: $e');
      rethrow;
    }
  }

  /// List enabled form templates
  ///
  /// GET /FaProSync.ashx?op=templates&companyId={X}
  Future<Map<String, dynamic>?> listTemplates({
    required String companyId,
  }) async {
    try {
      log('📋 Listing templates: companyId=$companyId');

      final url =
          '${ApiUrl.currentBaseUrl}/FaProSync.ashx?op=templates&companyId=$companyId';

      final response = await _dioClient.get(
        url: url,
        headers: ApiUrl.authHeaders,
      );

      if (response != null) {
        final count = response['count'] as int? ?? 0;
        log('✅ Templates response: $count items');
        return response;
      }

      log('⚠️ Templates response is null');
      return null;
    } catch (e) {
      log('❌ List templates error: $e');
      rethrow;
    }
  }

  /// Attach form templates to an appointment
  ///
  /// POST /FaProSync.ashx?op=attach
  /// Supports both single and multiple form attachment
  Future<Map<String, dynamic>?> attachTemplates({
    required String companyId,
    required String appointmentId,
    required List<int> templateIds,
    String? customerId,
    String? filledBy,
  }) async {
    try {
      log(
        '📎 Attaching templates: appointmentId=$appointmentId, templateIds=${templateIds.length}, customerId=$customerId',
      );

      final request = <String, dynamic>{
        'companyId': companyId,
        'appointmentId': appointmentId,
        'templateIds': templateIds,
        if (customerId != null && customerId.isNotEmpty)
          'customerId': customerId,
        if (filledBy != null && filledBy.isNotEmpty) 'filledBy': filledBy,
      };

      final response = await _dioClient.post(
        url: '${ApiUrl.currentBaseUrl}/FaProSync.ashx?op=attach',
        body: request,
        headers: ApiUrl.authHeaders,
      );
      kLog('📎 Attach templates response: ${jsonEncode(response)}');
      if (response != null) {
        final count = response['count'] as int? ?? 0;
        final success = response['success'] as bool? ?? false;
        log('✅ Attach response: success=$success, count=$count');

        // Check if any forms were already attached
        final items = response['items'] as List? ?? [];

        return response;
      }

      log('⚠️ Attach response is null');
      return null;
    } catch (e) {
      log('❌ Attach templates error: $e');
      rethrow;
    }
  }

  /// Send custom email with optional PDF attachment
  ///
  /// POST /fsm/FaProSync.ashx?op=sendEmail
  /// Allows complete control over email content and optional PDF attachment
  ///
  /// Per API spec (2026-06-02):
  /// - Required: companyId, to, subject, body
  /// - Optional: cc, customerId, formResponseId (for PDF attachment)
  /// - Returns success=true ONLY when pipeline returns "Sent"
  /// - Soft send failures return success=false with emailStatus/emailError
  Future<Map<String, dynamic>?> sendCustomEmail({
    required String companyId,
    required String to,
    required String subject,
    required String body,
    String? cc,
    String? customerId,
    int? formResponseId,
  }) async {
    try {
      log(
        '📧 Sending custom email: companyId=$companyId, to=$to, subject=$subject, cc=$cc, formResponseId=$formResponseId',
      );

      // Build request body per API specification
      final requestBody = <String, dynamic>{
        'companyId': companyId,
        'to': to,
        'subject': subject,
        'body': body,
      };

      // Add optional CC (comma-separated recipients supported)
      if (cc != null && cc.isNotEmpty) {
        requestBody['cc'] = cc;
      }

      // Add customerId for EmailHistory linking and [token] replacement
      if (customerId != null && customerId.isNotEmpty) {
        requestBody['customerId'] = customerId;
      }

      // Attach stamped PDF if formResponseId provided
      // PDF is attached if present on disk; missing PDF doesn't block send (attached=false)
      if (formResponseId != null && formResponseId > 0) {
        requestBody['formResponseId'] = formResponseId;
      }

      final response = await _dioClient.post(
        url: '${ApiUrl.currentBaseUrl}/FaProSync.ashx?op=sendEmail',
        body: requestBody,
        headers: ApiUrl.authHeaders,
      );

      if (response != null) {
        // Log full response for debugging
        log(
          '📧 Email API response: ${response['success']}, toEmail=${response['toEmail']}, '
          'attached=${response['attached']}, status=${response['emailStatus']}',
        );

        if (response['success'] == true) {
          log(
            '✅ Custom email sent successfully: to=${response['toEmail']}, subject=${response['subject']}, '
            'attached=${response['attached']}, status=${response['emailStatus']}',
          );
        } else {
          // Soft send failure (provider rejected but no exception)
          log(
            '⚠️ Custom email soft failed: status=${response['emailStatus']}, '
            'error=${response['emailError'] ?? response['error']}',
          );
        }
        return response;
      }

      log('⚠️ Custom email response is null');
      return null;
    } catch (e) {
      log('❌ Send custom email error: $e');
      rethrow;
    }
  }
}

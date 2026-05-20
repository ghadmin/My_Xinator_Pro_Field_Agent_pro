import 'dart:io';
import 'package:dio/dio.dart';
import '../service/REST/api_urls.dart';
import '../service/REST/dio_client.dart';
import '../../utils/klog.dart';

class FaProMobileApiService {
  final DioClient _dioClient = DioClient();
  final Dio _dio = Dio();

  /// Build URL with query parameters
  String _buildUrl({
    required String resource,
    required String operation,
    required String companyId,
    Map<String, String>? extraParams,
  }) {
    return ApiUrl.buildFaProMobileUrl(
      resource: resource,
      operation: operation,
      companyId: companyId,
      extraParams: extraParams,
    );
  }

  /// Get headers with API key
  Map<String, String> _getHeaders({bool isMultipart = false}) {
    if (isMultipart) {
      return ApiUrl.faProMobileAuthHeaders;
    }
    return ApiUrl.faProMobileJsonHeaders;
  }

  // ==================== NOTES ====================

  /// Get notes list for a customer and site
  Future<Map<String, dynamic>?> getNotesList({
    required String companyId,
    required String customerId,
    required int siteId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'notes',
        operation: 'list',
        companyId: companyId,
        extraParams: {'customerId': customerId, 'siteId': siteId.toString()},
      );

      kLog('GET $url');
      final response = await _dioClient.get(
        url: url,
        headers: _getHeaders(),
      );

      kLog('Notes list fetched: ${response['count'] ?? 0} items');
      return response;
    } catch (e) {
      kLog('Exception fetching notes: $e');
      return null;
    }
  }

  /// Create a new note
  Future<Map<String, dynamic>?> createNote({
    required String companyId,
    required String customerId,
    required int siteId,
    required String description,
    String? reference,
    String? taggedTo,
    String? taggedFrom,
    String? userId,
    String? appointmentId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'notes',
        operation: 'create',
        companyId: companyId,
      );

      final body = {
        'customerId': customerId,
        'siteId': siteId,
        'description': description,
        if (reference != null) 'reference': reference,
        if (taggedTo != null) 'taggedTo': taggedTo,
        if (taggedFrom != null) 'taggedFrom': taggedFrom,
        if (userId != null) 'userId': userId,
        if (appointmentId != null) 'appointmentId': appointmentId,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Note created: ${response['id']}');
      return response;
    } catch (e) {
      kLog('Exception creating note: $e');
      return null;
    }
  }

  /// Create multiple notes in a single batch request
  Future<Map<String, dynamic>?> createNotesBatch({
    required String companyId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'notes',
        operation: 'createBatch',
        companyId: companyId,
      );

      final body = {'items': items};

      kLog('POST $url (batch - ${items.length} notes)');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Notes batch created: ${response['count']} items');
      return response;
    } catch (e) {
      kLog('Exception creating notes batch: $e');
      return null;
    }
  }

  /// Update an existing note
  Future<Map<String, dynamic>?> updateNote({
    required String companyId,
    required int noteId,
    required String description,
    String? reference,
    String? taggedTo,
    String? taggedFrom,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'notes',
        operation: 'update',
        companyId: companyId,
      );

      final body = {
        'noteId': noteId,
        'description': description,
        if (reference != null) 'reference': reference,
        if (taggedTo != null) 'taggedTo': taggedTo,
        if (taggedFrom != null) 'taggedFrom': taggedFrom,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Note updated: $noteId');
      return response;
    } catch (e) {
      kLog('Exception updating note: $e');
      return null;
    }
  }

  /// Delete a note
  Future<Map<String, dynamic>?> deleteNote({
    required String companyId,
    required int noteId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'notes',
        operation: 'delete',
        companyId: companyId,
      );

      final body = {'noteId': noteId};

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Note deleted: $noteId');
      return response;
    } catch (e) {
      kLog('Exception deleting note: $e');
      return null;
    }
  }

  // ==================== PICTURES ====================

  /// Get pictures list for a customer and site
  Future<Map<String, dynamic>?> getPicturesList({
    required String companyId,
    required String customerId,
    required int siteId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'pictures',
        operation: 'list',
        companyId: companyId,
        extraParams: {'customerId': customerId, 'siteId': siteId.toString()},
      );

      kLog('GET $url');
      final response = await _dioClient.get(
        url: url,
        headers: _getHeaders(),
      );

      kLog('Pictures list fetched: ${response['count'] ?? 0} items');
      return response;
    } catch (e) {
      kLog('Exception fetching pictures: $e');
      return null;
    }
  }

  /// Upload a picture (multipart/form-data)
  Future<Map<String, dynamic>?> uploadPicture({
    required String companyId,
    required String customerId,
    required int siteId,
    required File file,
    String? appointmentId,
    String? reference,
    String? uploadedBy,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'pictures',
        operation: 'create',
        companyId: companyId,
      );

      final formData = FormData.fromMap({
        'customerId': customerId,
        'siteId': siteId.toString(),
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (reference != null) 'reference': reference,
        if (uploadedBy != null) 'uploadedBy': uploadedBy,
        'file': await MultipartFile.fromFile(file.path),
      });

      kLog('POST $url (multipart)');
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: _getHeaders(isMultipart: true)),
      );

      kLog('Picture uploaded: ${response.data}');
      return response.data;
    } catch (e) {
      kLog('Exception uploading picture: $e');
      return null;
    }
  }

  /// Upload multiple pictures in a single batch request (multipart/form-data)
  Future<Map<String, dynamic>?> uploadPicturesBatch({
    required String companyId,
    required String customerId,
    required int siteId,
    required List<File> files,
    String? appointmentId,
    String? reference,
    String? uploadedBy,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'pictures',
        operation: 'createBatch',
        companyId: companyId,
      );

      final Map<String, dynamic> formDataMap = {
        'customerId': customerId,
        'siteId': siteId.toString(),
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (reference != null) 'reference': reference,
        if (uploadedBy != null) 'uploadedBy': uploadedBy,
      };

      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        multipartFiles.add(await MultipartFile.fromFile(file.path));
      }

      formDataMap['file'] = multipartFiles;

      final formData = FormData.fromMap(formDataMap);

      kLog('POST $url (multipart batch - ${files.length} files)');
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: _getHeaders(isMultipart: true)),
      );

      kLog('Pictures batch uploaded: ${response.data}');
      return response.data;
    } catch (e) {
      kLog('Exception uploading pictures batch: $e');
      return null;
    }
  }

  /// Update picture metadata (reference only)
  Future<Map<String, dynamic>?> updatePicture({
    required String companyId,
    required int pictureId,
    required String reference,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'pictures',
        operation: 'update',
        companyId: companyId,
      );

      final body = {
        'pictureId': pictureId,
        'reference': reference,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Picture updated: $pictureId');
      return response;
    } catch (e) {
      kLog('Exception updating picture: $e');
      return null;
    }
  }

  /// Delete a picture
  Future<Map<String, dynamic>?> deletePicture({
    required String companyId,
    required int pictureId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'pictures',
        operation: 'delete',
        companyId: companyId,
      );

      final body = {'pictureId': pictureId};

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Picture deleted: $pictureId');
      return response;
    } catch (e) {
      kLog('Exception deleting picture: $e');
      return null;
    }
  }

  // ==================== FILES ====================

  /// Get files list for a customer and site
  Future<Map<String, dynamic>?> getFilesList({
    required String companyId,
    required String customerId,
    required int siteId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'files',
        operation: 'list',
        companyId: companyId,
        extraParams: {'customerId': customerId, 'siteId': siteId.toString()},
      );

      kLog('GET $url');
      final response = await _dioClient.get(
        url: url,
        headers: _getHeaders(),
      );

      kLog('Files list fetched: ${response['count'] ?? 0} items');
      return response;
    } catch (e) {
      kLog('Exception fetching files: $e');
      return null;
    }
  }

  /// Upload a file (multipart/form-data)
  Future<Map<String, dynamic>?> uploadFile({
    required String companyId,
    required String customerId,
    required int siteId,
    required File file,
    String? appointmentId,
    String? reference,
    String? uploadedBy,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'files',
        operation: 'create',
        companyId: companyId,
      );

      final formData = FormData.fromMap({
        'customerId': customerId,
        'siteId': siteId.toString(),
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (reference != null) 'reference': reference,
        if (uploadedBy != null) 'uploadedBy': uploadedBy,
        'file': await MultipartFile.fromFile(file.path),
      });

      kLog('POST $url (multipart)');
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: _getHeaders(isMultipart: true)),
      );

      kLog('File uploaded: ${response.data}');
      return response.data;
    } catch (e) {
      kLog('Exception uploading file: $e');
      return null;
    }
  }

  /// Upload multiple files in a single batch request (multipart/form-data)
  Future<Map<String, dynamic>?> uploadFilesBatch({
    required String companyId,
    required String customerId,
    required int siteId,
    required List<File> files,
    String? appointmentId,
    String? reference,
    String? uploadedBy,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'files',
        operation: 'createBatch',
        companyId: companyId,
      );

      final Map<String, dynamic> formDataMap = {
        'customerId': customerId,
        'siteId': siteId.toString(),
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (reference != null) 'reference': reference,
        if (uploadedBy != null) 'uploadedBy': uploadedBy,
      };

      final List<MultipartFile> multipartFiles = [];
      for (final file in files) {
        multipartFiles.add(await MultipartFile.fromFile(file.path));
      }

      formDataMap['file'] = multipartFiles;

      final formData = FormData.fromMap(formDataMap);

      kLog('POST $url (multipart batch - ${files.length} files)');
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: _getHeaders(isMultipart: true)),
      );

      kLog('Files batch uploaded: ${response.data}');
      return response.data;
    } catch (e) {
      kLog('Exception uploading files batch: $e');
      return null;
    }
  }

  /// Update file metadata
  Future<Map<String, dynamic>?> updateFile({
    required String companyId,
    required int fileId,
    String? fileName,
    String? reference,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'files',
        operation: 'update',
        companyId: companyId,
      );

      final body = {
        'fileId': fileId,
        if (fileName != null) 'fileName': fileName,
        if (reference != null) 'reference': reference,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('File updated: $fileId');
      return response;
    } catch (e) {
      kLog('Exception updating file: $e');
      return null;
    }
  }

  /// Delete a file
  Future<Map<String, dynamic>?> deleteFile({
    required String companyId,
    required int fileId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'files',
        operation: 'delete',
        companyId: companyId,
      );

      final body = {'fileId': fileId};

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('File deleted: $fileId');
      return response;
    } catch (e) {
      kLog('Exception deleting file: $e');
      return null;
    }
  }

  // ==================== EQUIPMENT ====================

  /// Get equipment list for a customer and site
  Future<Map<String, dynamic>?> getEquipmentList({
    required String companyId,
    required String customerGuid,
    required int siteId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'equipment',
        operation: 'list',
        companyId: companyId,
        extraParams: {
          'customerGuid': customerGuid,
          'siteId': siteId.toString(),
        },
      );

      kLog('GET $url');
      final response = await _dioClient.get(
        url: url,
        headers: _getHeaders(),
      );

      kLog('Equipment list fetched: ${response['count'] ?? 0} items');
      return response;
    } catch (e) {
      kLog('Exception fetching equipment: $e');
      return null;
    }
  }

  /// Get equipment types catalog
  Future<Map<String, dynamic>?> getEquipmentTypes({
    required String companyId,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'equipment',
        operation: 'equipmentTypes',
        companyId: companyId,
      );

      kLog('GET $url');
      final response = await _dioClient.get(
        url: url,
        headers: _getHeaders(),
      );

      kLog('Equipment types fetched: ${response['count'] ?? 0} items');
      return response;
    } catch (e) {
      kLog('Exception fetching equipment types: $e');
      return null;
    }
  }

  /// Create new equipment
  Future<Map<String, dynamic>?> createEquipment({
    required String companyId,
    required String customerId,
    required String customerGuid,
    required int siteId,
    String? make,
    String? model,
    String? notes,
    int? equipmentTypeId,
    String? barcode,
    String? serialNumber,
    String? warrantyStart,
    String? warrantyEnd,
    String? laborWarrantyStart,
    String? laborWarrantyEnd,
    String? installDate,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'equipment',
        operation: 'create',
        companyId: companyId,
      );

      final body = {
        'customerId': customerId,
        'customerGuid': customerGuid,
        'siteId': siteId,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (notes != null) 'notes': notes,
        if (equipmentTypeId != null) 'equipmentTypeId': equipmentTypeId,
        if (barcode != null) 'barcode': barcode,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (warrantyStart != null) 'warrantyStart': warrantyStart,
        if (warrantyEnd != null) 'warrantyEnd': warrantyEnd,
        if (laborWarrantyStart != null) 'laborWarrantyStart': laborWarrantyStart,
        if (laborWarrantyEnd != null) 'laborWarrantyEnd': laborWarrantyEnd,
        if (installDate != null) 'installDate': installDate,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Equipment created: ${response['id']}');
      return response;
    } catch (e) {
      kLog('Exception creating equipment: $e');
      return null;
    }
  }

  /// Update equipment
  Future<Map<String, dynamic>?> updateEquipment({
    required String companyId,
    required int id,
    required int siteId,
    required String customerId,
    required String customerGuid,
    String? make,
    String? model,
    String? notes,
    int? equipmentTypeId,
    String? barcode,
    String? serialNumber,
    String? warrantyStart,
    String? warrantyEnd,
    String? laborWarrantyStart,
    String? laborWarrantyEnd,
    String? installDate,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'equipment',
        operation: 'update',
        companyId: companyId,
      );

      final body = {
        'id': id,
        'siteId': siteId,
        'customerId': customerId,
        'customerGuid': customerGuid,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (notes != null) 'notes': notes,
        if (equipmentTypeId != null) 'equipmentTypeId': equipmentTypeId,
        if (barcode != null) 'barcode': barcode,
        if (serialNumber != null) 'serialNumber': serialNumber,
        if (warrantyStart != null) 'warrantyStart': warrantyStart,
        if (warrantyEnd != null) 'warrantyEnd': warrantyEnd,
        if (laborWarrantyStart != null) 'laborWarrantyStart': laborWarrantyStart,
        if (laborWarrantyEnd != null) 'laborWarrantyEnd': laborWarrantyEnd,
        if (installDate != null) 'installDate': installDate,
      };

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Equipment updated: $id');
      return response;
    } catch (e) {
      kLog('Exception updating equipment: $e');
      return null;
    }
  }

  /// Delete equipment
  Future<Map<String, dynamic>?> deleteEquipment({
    required String companyId,
    required int id,
  }) async {
    try {
      final url = _buildUrl(
        resource: 'equipment',
        operation: 'delete',
        companyId: companyId,
      );

      final body = {'id': id};

      kLog('POST $url');
      final response = await _dioClient.post(
        url: url,
        headers: _getHeaders(),
        body: body,
      );

      kLog('Equipment deleted: $id');
      return response;
    } catch (e) {
      kLog('Exception deleting equipment: $e');
      return null;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if response is successful
  bool isSuccess(Map<String, dynamic>? response) {
    return response != null && response['success'] == true;
  }

  /// Get error message from response
  String getErrorMessage(Map<String, dynamic>? response) {
    if (response == null) return 'Unknown error occurred';
    if (response['error'] != null) return response['error'].toString();
    return 'Operation failed';
  }
}

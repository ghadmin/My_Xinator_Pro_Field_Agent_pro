import 'package:dio/dio.dart';
import '../../../utils/klog.dart';
import '../data/local/my_shared_pref.dart';

class RAGService {
  static const String baseUrl = 'http://localhost:8000'; // Update with your RAG API URL
  static const String queryEndpoint = '/api/query';
  static const String syncEndpoint = '/api/sync';
  static const String statsEndpoint = '/api/stats';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// Query appointments using natural language
  Future<RAGQueryResponse?> queryAppointments(
    String question, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final userID = await MySharedPref.getUserName();
      final companyID = await MySharedPref.getCompanyID();

      final response = await _dio.post(
        queryEndpoint,
        data: {
          'question': question,
          'user_id': userID,
          'company_id': companyID,
          if (filters != null) 'filters': filters,
        },
      );

      if (response.statusCode == 200) {
        return RAGQueryResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      kLog('Error querying RAG service: $e');
      return null;
    }
  }

  /// Sync appointments to RAG system using the actual API response format
  Future<bool> syncAppointments(List<dynamic> appointments) async {
    try {
      final userID = await MySharedPref.getUserName();
      final companyID = await MySharedPref.getCompanyID();

      // Convert appointments to the format expected by RAG API
      final appointmentsData = appointments.map((apt) {
        if (apt is Map<String, dynamic>) {
          return apt;
        }
        return apt;
      }).toList();

      final response = await _dio.post(
        syncEndpoint,
        data: {
          'user_id': userID,
          'company_id': companyID,
          'appointments': appointmentsData,
        },
      );

      if (response.statusCode == 200) {
        final success = response.data['success'] ?? false;
        kLog('RAG sync result: $success, processed: ${response.data['appointments_processed']}');
        return success;
      }
      return false;
    } catch (e) {
      kLog('Error syncing to RAG service: $e');
      return false;
    }
  }

  /// Get RAG system statistics
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _dio.get(statsEndpoint);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      kLog('Error getting RAG stats: $e');
      return null;
    }
  }
}

class RAGQueryResponse {
  final String answer;
  final List<RAGSource> sources;
  final double? confidence;

  RAGQueryResponse({
    required this.answer,
    required this.sources,
    this.confidence,
  });

  factory RAGQueryResponse.fromJson(Map<String, dynamic> json) {
    return RAGQueryResponse(
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => RAGSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

class RAGSource {
  final String content;
  final RAGMetadata metadata;

  RAGSource({
    required this.content,
    required this.metadata,
  });

  factory RAGSource.fromJson(Map<String, dynamic> json) {
    return RAGSource(
      content: json['content'] as String? ?? '',
      metadata: RAGMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class RAGMetadata {
  final String? appointmentId;
  final String? title;
  final String? startDateTime;
  final String? status;
  final String? customerName;
  final String? type;
  final String? location;

  RAGMetadata({
    this.appointmentId,
    this.title,
    this.startDateTime,
    this.status,
    this.customerName,
    this.type,
    this.location,
  });

  factory RAGMetadata.fromJson(Map<String, dynamic> json) {
    return RAGMetadata(
      appointmentId: json['appointment_id'] as String?,
      title: json['title'] as String?,
      startDateTime: json['start_datetime'] as String?,
      status: json['status'] as String?,
      customerName: json['customer_name'] as String?,
      type: json['type'] as String?,
      location: json['location'] as String?,
    );
  }
}

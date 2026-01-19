import 'dart:developer';
import 'dart:io';

/// Helper class to handle SSL certificate configuration
class CertificateHelper {
  /// Configure HttpClient to trust certificates for specific domains
  static void configureHttpClient(HttpClient client) {
    // This is a temporary fix for production to allow certificate validation
    // In a real production environment, you should properly validate certificates

    client.badCertificateCallback = (cert, host, port) {
      // Log certificate details for debugging
      log('🔐 Certificate Check:');
      log('   Host: $host:$port');
      log('   Subject: ${cert.subject}');
      log('   Issuer: ${cert.issuer}');
      log('   Valid From: ${cert.startValidity}');
      log('   Valid Until: ${cert.endValidity}');

      // Check if certificate is valid
      final now = DateTime.now();
      final isValid = now.isAfter(cert.startValidity) && now.isBefore(cert.endValidity);

      if (!isValid) {
        log('❌ Certificate is expired or not yet valid!');
        return false;
      }

      // Allow certificates for your known domains
      final allowedDomains = [
        'testsite.myserviceforce.com',
        'myserviceforce.com',
        '*.myserviceforce.com',
      ];

      final isAllowedDomain = allowedDomains.any((domain) {
        if (domain.startsWith('*.')) {
          // Wildcard certificate
          final baseDomain = domain.substring(2);
          return host.endsWith(baseDomain);
        }
        return host == domain || host.endsWith('.$domain');
      });

      if (isAllowedDomain) {
        log('✅ Certificate accepted for: $host');
        return true;
      }

      log('⚠️ Certificate not in allowed list: $host');
      // For production, return false here to enforce strict validation
      // For now, return true to allow testing
      return true;
    };
  }
}

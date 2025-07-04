import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  // WhatsApp launcher with optional message
  static Future<void> whatsApp(String phoneNumber, {String? message}) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$phoneNumber',
      queryParameters: message != null ? {'text': message} : null,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not open WhatsApp for $phoneNumber');
    }
  }

  // Phone call launcher
  static Future<void> phoneCall(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not make a phone call to $phoneNumber');
    }
  }

  // Email launcher with optional subject and body
  static Future<void> email(String email,
      {String? subject, String? body}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: <String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not send an email to $email');
    }
  }

  // Website launcher with URL validation
  static Future<void> websiteUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw Exception('Invalid URL: $url');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch URL: $url');
    }
  }
}

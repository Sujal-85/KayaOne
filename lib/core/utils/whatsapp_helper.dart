import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String _phoneNumber = "917020232525";

  static Future<void> launchWhatsApp({String? message}) async {
    final String msg = message != null ? Uri.encodeComponent(message) : "";
    final Uri whatsappAppUri =
        Uri.parse("whatsapp://send?phone=$_phoneNumber&text=$msg");
    final Uri whatsappWebUri =
        Uri.parse("https://wa.me/$_phoneNumber?text=$msg");

    try {
      if (await canLaunchUrl(whatsappAppUri)) {
        await launchUrl(whatsappAppUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
    }
  }
}

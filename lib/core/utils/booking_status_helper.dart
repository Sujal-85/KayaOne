import 'package:flutter/material.dart';

enum BookingStage { review, collection, testing, report }

class BookingStatusHelper {
  static String getTitle(BookingStage stage) {
    switch (stage) {
      case BookingStage.review:
        return "Booking Under Review";
      case BookingStage.collection:
        return "Sample Collection";
      case BookingStage.testing:
        return "Testing in Progress";
      case BookingStage.report:
        return "Report Generated";
    }
  }

  static String getDescription(BookingStage stage) {
    switch (stage) {
      case BookingStage.review:
        return "We are verifying your slot details. Our team will contact you shortly.";
      case BookingStage.collection:
        return "Phlebotomist assigned. Drawing sample at your location.";
      case BookingStage.testing:
        return "Sample reached lab. Analyzers are processing your sample.";
      case BookingStage.report:
        return "Report is ready! Sent to your WhatsApp & available below.";
    }
  }

  static IconData getIcon(BookingStage stage) {
    switch (stage) {
      case BookingStage.review:
        return Icons.assignment_ind_rounded;
      case BookingStage.collection:
        return Icons.bloodtype_rounded;
      case BookingStage.testing:
        return Icons.science_rounded;
      case BookingStage.report:
        return Icons.verified_user_rounded;
    }
  }
}

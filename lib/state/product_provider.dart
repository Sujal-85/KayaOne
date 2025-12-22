import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'p1',
      'name': 'Dettol Antiseptic',
      'category': 'Medicine',
      'price': 150,
      'description':
          'Trusted protection against germs. Multiple sizes available.',
      'image': 'assets/images/products/dettol_antiseptic.png',
      'rating': 4.9,
      'discount': 5,
    },
    {
      'id': 'p2',
      'name': 'Whey Protein ISO',
      'category': 'Wellness',
      'price': 4500,
      'description':
          'Pure isolate whey protein for muscle recovery and growth.',
      'image': 'assets/images/products/whey_protein.png',
      'rating': 4.7,
      'discount': 20,
    },
    {
      'id': 'p3',
      'name': 'Digital B.P. Monitor',
      'category': 'Devices',
      'price': 2499,
      'description':
          'Fully automatic blood pressure monitor with large display.',
      'image': 'assets/images/products/bp_monitor.png',
      'rating': 4.6,
      'discount': 12,
    },
    {
      'id': 'p4',
      'name': 'N95 Face Mask',
      'category': 'Wellness',
      'price': 99,
      'description': 'Premium N95 respirators for maximum protection.',
      'image': 'assets/images/products/face_mask.png',
      'rating': 4.4,
      'discount': 0,
    },
    {
      'id': 'p5',
      'name': 'Omron Thermometer',
      'category': 'Devices',
      'price': 350,
      'description': 'Fast and accurate digital fever thermometer.',
      'image': 'assets/images/products/thermometer.png',
      'rating': 4.5,
      'discount': 8,
    },
  ];

  List<Map<String, dynamic>> get products => _products;

  List<Map<String, dynamic>> getProductsByCategory(String category) {
    if (category == "All") return _products;
    return _products.where((p) => p['category'] == category).toList();
  }
}

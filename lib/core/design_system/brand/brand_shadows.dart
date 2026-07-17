import 'package:flutter/material.dart';

abstract class BrandShadows {
  static const subtle = [
    BoxShadow(color: Color(0x102E2E2E), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const soft = [
    BoxShadow(color: Color(0x1A2E2E2E), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const elevated = [
    BoxShadow(color: Color(0x242E2E2E), blurRadius: 24, offset: Offset(0, 12)),
  ];
}

import 'package:flutter/material.dart';

abstract class CFShadows {
  static const soft = [
    BoxShadow(color: Color(0x1A2E2E2E), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const subtle = [
    BoxShadow(color: Color(0x102E2E2E), blurRadius: 10, offset: Offset(0, 4)),
  ];
}

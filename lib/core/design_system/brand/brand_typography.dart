import 'package:flutter/material.dart';

@immutable
class BrandTypography {
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle label;
  final TextStyle button;

  const BrandTypography({
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
    required this.label,
    required this.button,
  });

  static const standard = BrandTypography(
    headline: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFF2E2E2E),
    ),
    title: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2E2E2E),
    ),
    subtitle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6B655C),
    ),
    body: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF2E2E2E),
    ),
    caption: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF6B655C),
    ),
    label: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6B655C),
    ),
    button: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}

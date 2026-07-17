import 'package:flutter/material.dart';

@immutable
class BrandColors {
  final Color verdeValle;
  final Color verdeOscuro;
  final Color azulAndino;
  final Color oroInca;
  final Color marfil;
  final Color terracota;
  final Color piedra;
  final Color verdeExito;
  final Color rojoError;
  final Color amarilloAdvertencia;
  final Color azulInfo;
  final Color grisNeutro;
  final Color surface;
  final Color border;

  const BrandColors({
    required this.verdeValle,
    required this.verdeOscuro,
    required this.azulAndino,
    required this.oroInca,
    required this.marfil,
    required this.terracota,
    required this.piedra,
    required this.verdeExito,
    required this.rojoError,
    required this.amarilloAdvertencia,
    required this.azulInfo,
    required this.grisNeutro,
    required this.surface,
    required this.border,
  });

  static const standard = BrandColors(
    verdeValle: Color(0xFF4F6F52),
    verdeOscuro: Color(0xFF3D5B40),
    azulAndino: Color(0xFF2D4F73),
    oroInca: Color(0xFFC9A227),
    marfil: Color(0xFFF6F2E9),
    terracota: Color(0xFFC65D3D),
    piedra: Color(0xFF2E2E2E),
    verdeExito: Color(0xFF5E8C61),
    rojoError: Color(0xFFE15D3D),
    amarilloAdvertencia: Color(0xFFE0A430),
    azulInfo: Color(0xFF4B96C7),
    grisNeutro: Color(0xFF6B655C),
    surface: Color(0xFFFFFCF6),
    border: Color(0xFFD8CCB8),
  );
}

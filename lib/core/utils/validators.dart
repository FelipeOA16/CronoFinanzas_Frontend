import 'dart:convert';

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final req = validateRequired(value, 'Email');
    if (req != null) return req;
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z\d\-.]+$');
    if (!regex.hasMatch(value!.trim())) return 'Ingresa un email válido';
    return null;
  }

  static String? validatePassword(String? value) {
    final req = validateRequired(value, 'Contraseña');
    if (req != null) return req;
    if (value!.length < 8)
      return 'La contraseña debe tener al menos 8 caracteres';
    final bytes = utf8.encode(value);
    if (bytes.length > 72)
      return 'La contraseña excede el máximo permitido (72 bytes)';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final req = validateRequired(value, 'Confirmar contraseña');
    if (req != null) return req;
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? validateNombre(String? value) {
    return validateRequired(value, 'Nombre');
  }
}

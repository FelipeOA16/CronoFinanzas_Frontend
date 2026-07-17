import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum QuickCaptureBubbleStatus {
  unsupported,
  permissionRequired,
  inactive,
  starting,
  active,
  stopping,
  error;

  static QuickCaptureBubbleStatus fromNative(String? value) {
    return QuickCaptureBubbleStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => QuickCaptureBubbleStatus.error,
    );
  }
}

class QuickCapturePlatformService {
  static const MethodChannel _channel = MethodChannel(
    'cronofinanzas/quick_capture',
  );

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isOverlayPermissionGranted() async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isOverlayPermissionGranted') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> openOverlayPermissionSettings() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openOverlayPermissionSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<bool> startBubble({
    String? accessToken,
    required String apiBaseUrl,
    required List<Map<String, Object>> accounts,
  }) async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('startBubble', {
            if (accessToken != null && accessToken.isNotEmpty)
              'accessToken': accessToken,
            'apiBaseUrl': apiBaseUrl,
            'accounts': accounts,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> updateBubbleSnapshot({
    String? accessToken,
    required String apiBaseUrl,
    required List<Map<String, Object>> accounts,
  }) => syncSessionSnapshot(
    accessToken: accessToken,
    apiBaseUrl: apiBaseUrl,
    accounts: accounts,
  );

  Future<bool> syncSessionSnapshot({
    String? accessToken,
    required String apiBaseUrl,
    required List<Map<String, Object>> accounts,
  }) async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('updateBubbleSnapshot', {
            if (accessToken != null && accessToken.isNotEmpty)
              'accessToken': accessToken,
            'apiBaseUrl': apiBaseUrl,
            'accounts': accounts,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> stopBubble() => _invokeBool('stopBubble');

  Future<bool> isBubbleRunning() => _invokeBool('isBubbleRunning');

  Future<QuickCaptureBubbleStatus> getBubbleStatus() async {
    if (!isAndroid) return QuickCaptureBubbleStatus.unsupported;
    try {
      final value = await _channel.invokeMethod<String>('getBubbleStatus');
      return QuickCaptureBubbleStatus.fromNative(value);
    } on PlatformException {
      return QuickCaptureBubbleStatus.error;
    } on MissingPluginException {
      return QuickCaptureBubbleStatus.unsupported;
    }
  }

  Future<bool> isNotificationPermissionGranted() =>
      _invokeBool('isNotificationPermissionGranted');

  Future<bool> requestNotificationPermission() =>
      _invokeBool('requestNotificationPermission');

  Future<bool> isIgnoringBatteryOptimizations() =>
      _invokeBool('isIgnoringBatteryOptimizations');

  Future<void> openBatteryOptimizationSettings() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<bool> getRestoreOnBoot() => _invokeBool('getRestoreOnBoot');

  Future<bool> setRestoreOnBoot(bool enabled) async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('setRestoreOnBoot', {
            'enabled': enabled,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<QuickCaptureLaunchData?> consumeOpenQuickCaptureRequest() async {
    if (!isAndroid) return null;
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>(
        'consumeOpenQuickCaptureRequest',
      );
      if (data == null) return null;
      return QuickCaptureLaunchData(
        tipo: data['tipo'] as String?,
        monto: data['monto'] as String?,
        nota: data['nota'] as String?,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  void configureSessionProvider({
    required Future<String?> Function() getAccessToken,
    required String apiBaseUrl,
    required List<Map<String, Object>> Function() getAccounts,
    required void Function() onCaptureCreated,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getQuickCaptureSession':
          final token = await getAccessToken();
          if (token == null || token.isEmpty) return null;
          return <String, Object>{
            'accessToken': token,
            'apiBaseUrl': apiBaseUrl,
            'accounts': getAccounts(),
          };
        case 'notifyQuickCaptureCreated':
          onCaptureCreated();
          return true;
        default:
          throw MissingPluginException('Metodo no soportado: ${call.method}');
      }
    });
  }

  void clearSessionProvider() {
    _channel.setMethodCallHandler(null);
  }

  Future<bool> _invokeBool(String method) async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

class QuickCaptureLaunchData {
  final String? tipo;
  final String? monto;
  final String? nota;

  const QuickCaptureLaunchData({this.tipo, this.monto, this.nota});
}

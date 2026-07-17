package com.example.frontend

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var pendingQuickCaptureData: Map<String, String?>? = null
    private var notificationPermissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        readQuickCaptureRequest(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readQuickCaptureRequest(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            QUICK_CAPTURE_CHANNEL,
        )
        activeChannel = methodChannel
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isOverlayPermissionGranted" -> {
                    val granted =
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                            Settings.canDrawOverlays(this)
                    result.success(granted)
                }

                "openOverlayPermissionSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName"),
                        )
                        startActivity(intent)
                    }
                    result.success(null)
                }

                "startBubble" -> {
                    if (
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                        !Settings.canDrawOverlays(this)
                    ) {
                        result.success(false)
                    } else if (!hasNotificationPermission()) {
                        result.success(false)
                    } else {
                        val arguments = call.arguments as? Map<*, *>
                        val accounts = serializeAccounts(arguments)
                        val serviceIntent = Intent(
                            this,
                            QuickCaptureBubbleService::class.java,
                        ).apply {
                            action =
                                QuickCaptureBubbleService.ACTION_START_OR_UPDATE
                            val accessToken =
                                arguments?.get("accessToken") as? String
                            putExtra(
                                QuickCaptureBubbleService.EXTRA_SESSION_AVAILABLE,
                                !accessToken.isNullOrBlank(),
                            )
                            putExtra(
                                QuickCaptureBubbleService.EXTRA_ACCESS_TOKEN,
                                accessToken,
                            )
                            putExtra(
                                QuickCaptureBubbleService.EXTRA_API_BASE_URL,
                                arguments?.get("apiBaseUrl") as? String,
                            )
                            putExtra(
                                QuickCaptureBubbleService.EXTRA_ACCOUNTS_JSON,
                                accounts.toString(),
                            )
                        }
                        val started = runCatching {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent)
                            } else {
                                startService(serviceIntent)
                            }
                        }.isSuccess
                        result.success(started)
                    }
                }

                "updateBubbleSnapshot" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val accounts = serializeAccounts(arguments)
                    getSharedPreferences(
                        QuickCaptureBubbleService.PREFERENCES_NAME,
                        Context.MODE_PRIVATE,
                    ).edit()
                        .putString(
                            QuickCaptureBubbleService.KEY_API_BASE_URL,
                            arguments?.get("apiBaseUrl") as? String,
                        )
                        .putString(
                            QuickCaptureBubbleService.KEY_ACCOUNTS_JSON,
                            accounts.toString(),
                        )
                        .apply()
                    if (QuickCaptureBubbleService.isRunning) {
                        startService(
                            Intent(
                                this,
                                QuickCaptureBubbleService::class.java,
                            ).apply {
                                action =
                                    QuickCaptureBubbleService.ACTION_START_OR_UPDATE
                                val accessToken =
                                    arguments?.get("accessToken") as? String
                                putExtra(
                                    QuickCaptureBubbleService.EXTRA_SESSION_AVAILABLE,
                                    !accessToken.isNullOrBlank(),
                                )
                                putExtra(
                                    QuickCaptureBubbleService.EXTRA_ACCESS_TOKEN,
                                    accessToken,
                                )
                                putExtra(
                                    QuickCaptureBubbleService.EXTRA_API_BASE_URL,
                                    arguments?.get("apiBaseUrl") as? String,
                                )
                                putExtra(
                                    QuickCaptureBubbleService.EXTRA_ACCOUNTS_JSON,
                                    accounts.toString(),
                                )
                            },
                        )
                    }
                    result.success(true)
                }

                "stopBubble" -> {
                    if (QuickCaptureBubbleService.isRunning) {
                        startService(
                            Intent(this, QuickCaptureBubbleService::class.java)
                                .apply {
                                    action = QuickCaptureBubbleService.ACTION_STOP
                                },
                        )
                        stopService(
                            Intent(this, QuickCaptureBubbleService::class.java),
                        )
                    }
                    getSharedPreferences(
                        QuickCaptureBubbleService.PREFERENCES_NAME,
                        Context.MODE_PRIVATE,
                    ).edit()
                        .putBoolean(
                            QuickCaptureBubbleService.KEY_BUBBLE_ENABLED,
                            false,
                        )
                        .apply()
                    result.success(true)
                }

                "isBubbleRunning" -> {
                    result.success(QuickCaptureBubbleService.isRunning)
                }

                "getBubbleStatus" -> {
                    result.success(resolveBubbleStatus())
                }

                "isNotificationPermissionGranted" -> {
                    result.success(hasNotificationPermission())
                }

                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        result.success(true)
                    } else if (hasNotificationPermission()) {
                        result.success(true)
                    } else if (notificationPermissionResult != null) {
                        result.success(false)
                    } else {
                        notificationPermissionResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                            REQUEST_POST_NOTIFICATIONS,
                        )
                    }
                }

                "isIgnoringBatteryOptimizations" -> {
                    val powerManager =
                        getSystemService(POWER_SERVICE) as PowerManager
                    result.success(
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                            powerManager.isIgnoringBatteryOptimizations(
                                packageName,
                            ),
                    )
                }

                "openBatteryOptimizationSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(
                            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS),
                        )
                    }
                    result.success(null)
                }

                "getRestoreOnBoot" -> {
                    val persisted = getSharedPreferences(
                        QuickCaptureBubbleService.PREFERENCES_NAME,
                        Context.MODE_PRIVATE,
                    ).getBoolean(
                        QuickCaptureBubbleService.KEY_RESTORE_ON_BOOT,
                        false,
                    )
                    result.success(persisted)
                }

                "setRestoreOnBoot" -> {
                    val enabled =
                        (call.arguments as? Map<*, *>)?.get("enabled") as? Boolean
                            ?: false
                    getSharedPreferences(
                        QuickCaptureBubbleService.PREFERENCES_NAME,
                        Context.MODE_PRIVATE,
                    ).edit()
                        .putBoolean(
                            QuickCaptureBubbleService.KEY_RESTORE_ON_BOOT,
                            enabled,
                        )
                        .apply()
                    result.success(true)
                }

                "consumeOpenQuickCaptureRequest" -> {
                    val data = pendingQuickCaptureData
                    pendingQuickCaptureData = null
                    result.success(data)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_POST_NOTIFICATIONS) {
            notificationPermissionResult?.success(
                grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
            )
            notificationPermissionResult = null
        }
    }

    override fun onDestroy() {
        activeChannel = null
        notificationPermissionResult = null
        super.onDestroy()
    }

    private fun serializeAccounts(arguments: Map<*, *>?): JSONArray {
        val accounts = JSONArray()
        (arguments?.get("accounts") as? List<*>)
            .orEmpty()
            .forEach { raw ->
                val values = raw as? Map<*, *> ?: return@forEach
                accounts.put(
                    JSONObject().apply {
                        put("id", values["id"])
                        put("name", values["name"])
                        put("currency", values["currency"])
                    },
                )
            }
        return accounts
    }

    private fun hasNotificationPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun resolveBubbleStatus(): String {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(this)
        ) {
            return "permissionRequired"
        }
        if (!hasNotificationPermission()) return "permissionRequired"
        if (QuickCaptureBubbleService.isRunning) return "active"
        val enabled = getSharedPreferences(
            QuickCaptureBubbleService.PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        ).getBoolean(
            QuickCaptureBubbleService.KEY_BUBBLE_ENABLED,
            false,
        )
        return if (enabled) "starting" else "inactive"
    }

    private fun readQuickCaptureRequest(intent: Intent?) {
        if (
            intent?.getBooleanExtra(
                QuickCaptureBubbleService.EXTRA_OPEN_QUICK_CAPTURE,
                false,
            ) == true
        ) {
            pendingQuickCaptureData = mapOf(
                "tipo" to intent.getStringExtra(
                    QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_TYPE,
                ),
                "monto" to intent.getStringExtra(
                    QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_AMOUNT,
                ),
                "nota" to intent.getStringExtra(
                    QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_NOTE,
                ),
            )
            intent.removeExtra(
                QuickCaptureBubbleService.EXTRA_OPEN_QUICK_CAPTURE,
            )
            intent.removeExtra(
                QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_TYPE,
            )
            intent.removeExtra(
                QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_AMOUNT,
            )
            intent.removeExtra(
                QuickCaptureBubbleService.EXTRA_QUICK_CAPTURE_NOTE,
            )
        }
    }

    companion object {
        private const val QUICK_CAPTURE_CHANNEL =
            "cronofinanzas/quick_capture"
        private const val REQUEST_POST_NOTIFICATIONS = 2402

        @Volatile
        private var activeChannel: MethodChannel? = null

        fun requestQuickCaptureSession(
            callback: (Map<String, Any>?) -> Unit,
        ) {
            val channel = activeChannel
            if (channel == null) {
                callback(null)
                return
            }
            Handler(Looper.getMainLooper()).post {
                val delivered = AtomicBoolean(false)
                val timeout = Runnable {
                    if (delivered.compareAndSet(false, true)) callback(null)
                }
                Handler(Looper.getMainLooper()).postDelayed(timeout, 1_500)
                channel.invokeMethod(
                    "getQuickCaptureSession",
                    null,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            if (!delivered.compareAndSet(false, true)) return
                            val values = result as? Map<*, *>
                            val token = values?.get("accessToken") as? String
                            val baseUrl = values?.get("apiBaseUrl") as? String
                            if (token.isNullOrBlank() || baseUrl.isNullOrBlank()) {
                                callback(null)
                            } else {
                                callback(
                                    mapOf(
                                        "accessToken" to token,
                                        "apiBaseUrl" to baseUrl,
                                        "accounts" to
                                            (values["accounts"] as? List<*>
                                                ?: emptyList<Any>()),
                                    ),
                                )
                            }
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?,
                        ) {
                            if (delivered.compareAndSet(false, true)) {
                                callback(null)
                            }
                        }

                        override fun notImplemented() {
                            if (delivered.compareAndSet(false, true)) {
                                callback(null)
                            }
                        }
                    },
                )
            }
        }

        fun notifyQuickCaptureCreated() {
            val channel = activeChannel ?: return
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("notifyQuickCaptureCreated", null)
            }
        }
    }
}

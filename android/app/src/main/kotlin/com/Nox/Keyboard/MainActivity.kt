package com.Nox.Keyboard

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val APP_CHANNEL = "com.nox.keyboard/app"
    private var appChannel: MethodChannel? = null
    private var pendingTargetRoute: String? = null
    private var soundEngine: KeySoundEngine? = null
    private var otaManager: OtaUpdateManager? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        soundEngine = KeySoundEngine(this).apply { init() }
        otaManager = OtaUpdateManager(this).apply {
            cleanupAfterInstallIfNeeded()
            checkIfDueBackground(minIntervalMs = 15 * 60 * 1000L)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.attributes = window.attributes.apply {
                preferredRefreshRate = 60.0f
            }
        }
        handleIntentExtras(intent)
    }

    override fun onResume() {
        super.onResume()
        otaManager?.cleanupAfterInstallIfNeeded()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentExtras(intent)
    }

    private fun handleIntentExtras(intent: Intent?) {
        if (intent == null) return
        val targetRoute = intent.getStringExtra("targetRoute")
        if (!targetRoute.isNullOrEmpty()) {
            pendingTargetRoute = targetRoute
            appChannel?.invokeMethod("onNavigateRoute", targetRoute)
            intent.removeExtra("targetRoute")
        }
        if (intent.getBooleanExtra("requestAudioPermission", false)) {
            intent.removeExtra("requestAudioPermission")
            requestAudioPermission()
        }
        if (intent.getBooleanExtra("requestMediaPermission", false)) {
            intent.removeExtra("requestMediaPermission")
            requestMediaPermission()
        }
    }

    private fun requestMediaPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_IMAGES
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
        if (ContextCompat.checkSelfPermission(this, perm) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(perm), 1002)
        }
    }

    private fun requestAudioPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 1001)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHANNEL)
        appChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isKeyboardEnabled" -> {
                    try {
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        val enabledList = imm.enabledInputMethodList
                        val isEnabled = enabledList.any { it.packageName == packageName }
                        result.success(isEnabled)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "isKeyboardDefault" -> {
                    try {
                        val currentIme = Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
                        val isDefault = currentIme != null && currentIme.contains(packageName)
                        result.success(isDefault)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "openInputMethodSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                "showInputMethodPicker" -> {
                    try {
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        imm.showInputMethodPicker()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("PICKER_ERROR", e.message, null)
                    }
                }
                "getInitialRouteExtra" -> {
                    val r = pendingTargetRoute
                    pendingTargetRoute = null
                    result.success(r)
                }
                "requestAudioPermission" -> {
                    requestAudioPermission()
                    result.success(true)
                }
                "performHaptic" -> {
                    val durationMs = (call.argument<Int>("duration") ?: 20).toLong()
                    performHaptic(durationMs)
                    result.success(true)
                }
                "playKeySound" -> {
                    val effect = call.argument<Int>("effect") ?: 0
                    val style = call.argument<String>("style") ?: "soft"
                    val volume = (call.argument<Double>("volume") ?: 0.7).toFloat()
                    soundEngine?.play(style, volume, effect)
                    result.success(true)
                }
                "getAppVersion" -> {
                    result.success(otaManager?.getInstalledVersionName() ?: "1.0.0")
                }
                "checkForUpdate" -> {
                    val notify = call.argument<Boolean>("notify") ?: false
                    otaManager?.checkForUpdate(notifyIfNew = notify) { data ->
                        result.success(data)
                    }
                }
                "downloadAndInstallUpdate" -> {
                    val url = call.argument<String>("url") ?: ""
                    val tag = call.argument<String>("tag") ?: ""
                    otaManager?.downloadAndInstall(
                        apkUrl = url,
                        versionTag = tag,
                        onProgress = { pct, downloaded, total ->
                            appChannel?.invokeMethod("onOtaProgress", hashMapOf(
                                "percent" to pct,
                                "downloaded" to downloaded,
                                "total" to total
                            ))
                        },
                        onFinished = { status, msg ->
                            appChannel?.invokeMethod("onOtaComplete", hashMapOf(
                                "status" to status,
                                "message" to msg
                            ))
                        }
                    )
                    result.success(true)
                }
                "canRequestPackageInstalls" -> {
                    result.success(otaManager?.canRequestPackageInstalls() ?: true)
                }
                "openInstallPermissionSettings" -> {
                    otaManager?.openInstallPermissionSettings()
                    result.success(true)
                }
                "hasNotificationPermission" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    } else true
                    result.success(granted)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1003)
                    }
                    result.success(true)
                }
                "getAutoCheckUpdates" -> {
                    result.success(otaManager?.isAutoCheckEnabled() ?: true)
                }
                "setAutoCheckUpdates" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    otaManager?.setAutoCheckEnabled(enabled)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        soundEngine?.release()
        soundEngine = null
        super.onDestroy()
    }

    private fun performHaptic(durationMs: Long) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vm?.defaultVibrator?.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                val v = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    v?.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    v?.vibrate(durationMs)
                }
            }
        } catch (_: Exception) {}
    }
}

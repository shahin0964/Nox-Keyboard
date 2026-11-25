package com.Nox.Keyboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.text.InputType
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class NoxInputMethodService : InputMethodService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var channel: MethodChannel? = null

    companion object {
        const val CHANNEL_NAME = "com.nox.keyboard/ime"
    }

    override fun onCreate() {
        super.onCreate()
        initFlutterEngine()
    }

    private fun initFlutterEngine() {
        if (flutterEngine == null) {
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(applicationContext)
            }
            loader.ensureInitializationComplete(applicationContext, null)

            flutterEngine = FlutterEngine(this)
            flutterEngine?.navigationChannel?.setInitialRoute("/ime")
            flutterEngine?.dartExecutor?.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_NAME)
            setupChannelHandlers()
        }
    }

    private fun setupChannelHandlers() {
        channel?.setMethodCallHandler { call, result ->
            val ic = currentInputConnection
            when (call.method) {
                "commitText" -> {
                    val text = call.argument<String>("text") ?: ""
                    ic?.commitText(text, 1)
                    result.success(true)
                }
                "deleteBackward" -> {
                    val selected = ic?.getSelectedText(0)
                    if (!selected.isNullOrEmpty()) {
                        ic.commitText("", 1)
                    } else {
                        ic?.deleteSurroundingText(1, 0)
                    }
                    result.success(true)
                }
                "deleteForward" -> {
                    ic?.deleteSurroundingText(0, 1)
                    result.success(true)
                }
                "deleteWordBackward" -> {
                    val before = ic?.getTextBeforeCursor(50, 0)?.toString() ?: ""
                    if (before.isNotEmpty()) {
                        val trimmed = before.trimEnd()
                        val lastSpace = trimmed.lastIndexOfAny(charArrayOf(' ', '\n', '\t', ',', '.', '!', '?'))
                        val deleteLen = if (lastSpace == -1) {
                            before.length
                        } else {
                            before.length - (lastSpace + 1)
                        }
                        ic?.deleteSurroundingText(deleteLen.coerceAtLeast(1), 0)
                    } else {
                        ic?.deleteSurroundingText(1, 0)
                    }
                    result.success(true)
                }
                "performEditorAction" -> {
                    val action = call.argument<Int>("action") ?: EditorInfo.IME_ACTION_UNSPECIFIED
                    if (action != EditorInfo.IME_ACTION_UNSPECIFIED) {
                        ic?.performEditorAction(action)
                    } else {
                        sendDownUpKeyEvents(KeyEvent.KEYCODE_ENTER)
                    }
                    result.success(true)
                }
                "sendKeyEvent" -> {
                    val keyCode = call.argument<Int>("keyCode") ?: KeyEvent.KEYCODE_ENTER
                    sendDownUpKeyEvents(keyCode)
                    result.success(true)
                }
                "moveCursor" -> {
                    val delta = call.argument<Int>("delta") ?: 0
                    if (delta < 0) {
                        for (i in 0 until -delta) {
                            sendDownUpKeyEvents(KeyEvent.KEYCODE_DPAD_LEFT)
                        }
                    } else if (delta > 0) {
                        for (i in 0 until delta) {
                            sendDownUpKeyEvents(KeyEvent.KEYCODE_DPAD_RIGHT)
                        }
                    }
                    result.success(true)
                }
                "setSelection" -> {
                    val start = call.argument<Int>("start") ?: 0
                    val end = call.argument<Int>("end") ?: 0
                    ic?.setSelection(start, end)
                    result.success(true)
                }
                "hideKeyboard" -> {
                    requestHideSelf(0)
                    result.success(true)
                }
                "switchToNextIme" -> {
                    val switched = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        switchToNextInputMethod(false)
                    } else {
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                        @Suppress("DEPRECATION")
                        imm.switchToNextInputMethod(window.window?.attributes?.token, false)
                    }
                    result.success(switched)
                }
                "openSettings" -> {
                    val intent = Intent(this@NoxInputMethodService, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "getClipboardText" -> {
                    try {
                        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clip = cm.primaryClip
                        if (clip != null && clip.itemCount > 0) {
                            val text = clip.getItemAt(0).coerceToText(this@NoxInputMethodService).toString()
                            result.success(text)
                        } else {
                            result.success("")
                        }
                    } catch (e: Exception) {
                        result.success("")
                    }
                }
                "setClipboardText" -> {
                    val text = call.argument<String>("text") ?: ""
                    try {
                        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clip = ClipData.newPlainText("Nox Keyboard", text)
                        cm.setPrimaryClip(clip)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLIPBOARD_ERROR", e.message, null)
                    }
                }
                "playKeySound" -> {
                    try {
                        val effect = call.argument<Int>("effect") ?: AudioManager.FX_KEYPRESS_STANDARD
                        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        am.playSoundEffect(effect)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "performHaptic" -> {
                    val durationMs = (call.argument<Int>("duration") ?: 15).toLong()
                    performHaptic(durationMs)
                    result.success(true)
                }
                "getTextBeforeCursor" -> {
                    val length = call.argument<Int>("length") ?: 100
                    val text = ic?.getTextBeforeCursor(length, 0)?.toString() ?: ""
                    result.success(text)
                }
                "getTextAfterCursor" -> {
                    val length = call.argument<Int>("length") ?: 100
                    val text = ic?.getTextAfterCursor(length, 0)?.toString() ?: ""
                    result.success(text)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreateInputView(): View {
        initFlutterEngine()
        if (flutterView == null) {
            val textureView = FlutterTextureView(this)
            flutterView = FlutterView(this, textureView)
            flutterView!!.attachToFlutterEngine(flutterEngine!!)
            flutterView!!.layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        return flutterView!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        if (info == null) return

        val inputType = info.inputType
        val imeOptions = info.imeOptions
        val actionId = info.actionId
        val actionLabel = info.actionLabel?.toString() ?: ""
        val packageName = info.packageName ?: ""

        val typeClass = inputType and InputType.TYPE_MASK_CLASS
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        val isPassword = (typeClass == InputType.TYPE_CLASS_TEXT) && (
            variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD
        )

        val isNumber = (typeClass == InputType.TYPE_CLASS_NUMBER || typeClass == InputType.TYPE_CLASS_PHONE)
        val isEmail = (variation == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS || variation == InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS)
        val isUri = (variation == InputType.TYPE_TEXT_VARIATION_URI)

        val beforeText = currentInputConnection?.getTextBeforeCursor(50, 0)?.toString() ?: ""

        val data = hashMapOf<String, Any>(
            "inputType" to inputType,
            "imeOptions" to imeOptions,
            "actionId" to actionId,
            "actionLabel" to actionLabel,
            "packageName" to packageName,
            "isPassword" to isPassword,
            "isNumber" to isNumber,
            "isEmail" to isEmail,
            "isUri" to isUri,
            "textBeforeCursor" to beforeText
        )

        channel?.invokeMethod("onStartInput", data)
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        channel?.invokeMethod("onFinishInput", null)
        super.onFinishInputView(finishingInput)
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

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDestroy()
    }
}

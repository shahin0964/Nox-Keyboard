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
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.text.InputType
import android.widget.FrameLayout
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class NoxInputMethodService : InputMethodService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var inputContainer: InputViewContainer? = null
    private var channel: MethodChannel? = null

    companion object {
        const val CHANNEL_NAME = "com.nox.keyboard/ime"
    }

    /**
     * Custom FrameLayout container that enforces exact measured height for the Android IME window.
     * Incorporates both content height (Gboard size: ~260dp) and the Android system navigation bar height (~36dp).
     * This lifts all keys completely above the Android navigation gesture pill and keyboard switcher.
     */
    class InputViewContainer(context: Context) : FrameLayout(context) {
        var contentHeightDp: Float = 260f
        var navBarHeightDp: Float = 60f

        init {
            val detected = detectNavBarHeightDp()
            if (detected > 60f) {
                navBarHeightDp = detected
            }
        }

        private fun detectNavBarHeightDp(): Float {
            val density = context.resources.displayMetrics.density
            val resId = context.resources.getIdentifier("navigation_bar_height", "dimen", "android")
            val px = if (resId > 0) context.resources.getDimensionPixelSize(resId) else (36 * density).toInt()
            val dp = px / density
            return if (dp >= 24f && dp <= 48f) dp else 36f
        }

        fun updateDimensions(contentDp: Float, navDp: Float?) {
            contentHeightDp = contentDp
            if (navDp != null && navDp > 0) {
                navBarHeightDp = navDp
            }
            requestLayout()
        }

        fun getTotalHeightPx(): Int {
            val density = context.resources.displayMetrics.density
            return ((contentHeightDp + navBarHeightDp) * density).toInt()
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            val width = MeasureSpec.getSize(widthMeasureSpec)
            val totalPx = getTotalHeightPx()
            val exactHeightSpec = MeasureSpec.makeMeasureSpec(totalPx, MeasureSpec.EXACTLY)
            super.onMeasure(widthMeasureSpec, exactHeightSpec)
            setMeasuredDimension(width, totalPx)
        }
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
                "updateKeyboardDimensions" -> {
                    val contentDp = (call.argument<Double>("contentHeight") ?: 260.0).toFloat()
                    val navDp = call.argument<Double>("navBarHeight")?.toFloat()
                    inputContainer?.updateDimensions(contentDp, navDp)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onConfigureWindow(win: Window, isFullscreen: Boolean, isCandidatesOnly: Boolean) {
        super.onConfigureWindow(win, isFullscreen, isCandidatesOnly)
        win.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        win.setGravity(Gravity.BOTTOM)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            win.attributes = win.attributes.apply {
                preferredRefreshRate = 60.0f
            }
        }
    }

    override fun onEvaluateFullscreenMode(): Boolean {
        // Never allow full-screen extract mode; keep keyboard pinned to bottom
        return false
    }

    override fun onEvaluateInputViewShown(): Boolean {
        return true
    }

    override fun onCreateInputView(): View {
        initFlutterEngine()
        if (inputContainer == null) {
            inputContainer = InputViewContainer(this)
            val textureView = FlutterTextureView(this)
            flutterView = FlutterView(this, textureView)
            flutterView!!.attachToFlutterEngine(flutterEngine!!)
            inputContainer!!.addView(
                flutterView,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
            )
        }
        return inputContainer!!
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
        val navBarDp = inputContainer?.navBarHeightDp ?: 36f

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
            "textBeforeCursor" to beforeText,
            "navBarHeightDp" to navBarDp
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
        inputContainer?.removeAllViews()
        flutterView = null
        inputContainer = null
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDestroy()
    }
}

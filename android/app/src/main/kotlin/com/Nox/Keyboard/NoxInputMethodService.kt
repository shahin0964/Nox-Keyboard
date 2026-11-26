package com.Nox.Keyboard

import android.Manifest
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.MediaStore
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.text.InputType
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.view.inputmethod.EditorInfoCompat
import androidx.core.view.inputmethod.InputConnectionCompat
import androidx.core.view.inputmethod.InputContentInfoCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class NoxInputMethodService : InputMethodService() {
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var inputContainer: InputViewContainer? = null
    private var channel: MethodChannel? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private var currentEditorInfo: EditorInfo? = null
    private val mainHandler = Handler(Looper.getMainLooper())

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
            flutterEngine?.lifecycleChannel?.appIsResumed()
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
                    requestHideSelf(0)
                    val intent = Intent(this@NoxInputMethodService, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        putExtra("targetRoute", "/typing-settings")
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "performContextMenuAction" -> {
                    val actionId = call.argument<Int>("actionId") ?: 0
                    val ok = ic?.performContextMenuAction(actionId) ?: false
                    result.success(ok)
                }
                "startVoiceRecognition" -> {
                    val langCode = call.argument<String>("languageCode") ?: "en_US"
                    val started = startVoiceRecognition(langCode)
                    result.success(started)
                }
                "stopVoiceRecognition" -> {
                    stopVoiceRecognition()
                    result.success(true)
                }
                "requestAudioPermission" -> {
                    requestHideSelf(0)
                    val intent = Intent(this@NoxInputMethodService, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        putExtra("requestAudioPermission", true)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "getMediaClipboardState" -> {
                    val img = captureClipboardImagePath() ?: ""
                    val ss = getRecentScreenshotPath() ?: ""
                    result.success(hashMapOf(
                        "hasPermission" to hasMediaPermission(),
                        "clipboardImagePath" to img,
                        "screenshotPath" to ss
                    ))
                }
                "commitImage" -> {
                    val path = call.argument<String>("path") ?: ""
                    val status = commitImagePath(path, ic)
                    result.success(status)
                }
                "requestMediaPermission" -> {
                    requestHideSelf(0)
                    val intent = Intent(this@NoxInputMethodService, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        putExtra("requestMediaPermission", true)
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
        win.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
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
        } else {
            (inputContainer?.parent as? ViewGroup)?.removeView(inputContainer)
        }
        flutterEngine?.lifecycleChannel?.appIsResumed()
        return inputContainer!!
    }

    override fun onWindowShown() {
        super.onWindowShown()
        flutterEngine?.lifecycleChannel?.appIsResumed()
        flutterView?.let { fv ->
            if (!fv.isAttachedToFlutterEngine() && flutterEngine != null) {
                fv.attachToFlutterEngine(flutterEngine!!)
            }
            fv.requestLayout()
            fv.invalidate()
        }
        inputContainer?.requestLayout()
    }

    override fun onWindowHidden() {
        flutterEngine?.lifecycleChannel?.appIsInactive()
        super.onWindowHidden()
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        flutterEngine?.lifecycleChannel?.appIsResumed()
        flutterView?.invalidate()
        currentEditorInfo = info
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
        val navBarDp = inputContainer?.navBarHeightDp ?: 60f
        val clipboardText = try {
            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = cm.primaryClip
            if (clip != null && clip.itemCount > 0) {
                clip.getItemAt(0).coerceToText(this@NoxInputMethodService)?.toString() ?: ""
            } else ""
        } catch (_: Exception) {
            ""
        }

        val clipboardImagePath = captureClipboardImagePath() ?: getRecentScreenshotPath() ?: ""

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
            "navBarHeightDp" to navBarDp,
            "clipboardText" to clipboardText,
            "clipboardImagePath" to clipboardImagePath
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

    private fun startVoiceRecognition(languageCode: String): Boolean {
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            channel?.invokeMethod("onVoiceError", "PERMISSION_REQUIRED")
            return false
        }
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            channel?.invokeMethod("onVoiceError", "UNAVAILABLE")
            return false
        }

        val localeTag = when (languageCode) {
            "bn_avro", "bn_BD" -> "bn-BD"
            "hi" -> "hi-IN"
            "ar" -> "ar-SA"
            "ur" -> "ur-PK"
            else -> "en-US"
        }

        mainHandler.post {
            try {
                speechRecognizer?.destroy()
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this).apply {
                    setRecognitionListener(object : RecognitionListener {
                        override fun onReadyForSpeech(params: Bundle?) {
                            channel?.invokeMethod("onVoiceState", "listening")
                        }
                        override fun onBeginningOfSpeech() {
                            channel?.invokeMethod("onVoiceState", "speaking")
                        }
                        override fun onRmsChanged(rmsdB: Float) {}
                        override fun onBufferReceived(buffer: ByteArray?) {}
                        override fun onEndOfSpeech() {
                            channel?.invokeMethod("onVoiceState", "processing")
                        }
                        override fun onError(error: Int) {
                            val msg = when (error) {
                                SpeechRecognizer.ERROR_NO_MATCH,
                                SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "NO_SPEECH"
                                SpeechRecognizer.ERROR_NETWORK,
                                SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "NETWORK"
                                SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "PERMISSION_REQUIRED"
                                else -> "ERROR_$error"
                            }
                            channel?.invokeMethod("onVoiceError", msg)
                        }
                        override fun onResults(results: Bundle?) {
                            val list = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                            val text = list?.firstOrNull() ?: ""
                            channel?.invokeMethod("onVoiceResult", hashMapOf("text" to text, "isFinal" to true))
                        }
                        override fun onPartialResults(partialResults: Bundle?) {
                            val list = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                            val text = list?.firstOrNull() ?: ""
                            if (text.isNotEmpty()) {
                                channel?.invokeMethod("onVoiceResult", hashMapOf("text" to text, "isFinal" to false))
                            }
                        }
                        override fun onEvent(eventType: Int, params: Bundle?) {}
                    })
                }
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeTag)
                    putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                    putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                }
                speechRecognizer?.startListening(intent)
            } catch (_: Exception) {
                channel?.invokeMethod("onVoiceError", "UNAVAILABLE")
            }
        }
        return true
    }

    private fun stopVoiceRecognition() {
        mainHandler.post {
            try {
                speechRecognizer?.stopListening()
            } catch (_: Exception) {}
        }
    }

    private fun hasMediaPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun getClipImagesDir(): File {
        val dir = File(cacheDir, "clip_images")
        if (!dir.exists()) dir.mkdirs()
        return dir
    }

    private fun copyUriToCache(uri: Uri, prefix: String): String? {
        return try {
            val mime = contentResolver.getType(uri) ?: "image/png"
            val ext = if (mime.contains("png", true)) "png" else "jpg"
            val name = "${prefix}_${uri.toString().hashCode().toUInt()}.$ext"
            val outFile = File(getClipImagesDir(), name)
            if (outFile.exists() && outFile.length() > 0) {
                return outFile.absolutePath
            }
            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(outFile).use { output ->
                    val buffer = ByteArray(8192)
                    var total = 0
                    while (true) {
                        val read = input.read(buffer)
                        if (read == -1) break
                        total += read
                        if (total > 6 * 1024 * 1024) break // cap at 6MB
                        output.write(buffer, 0, read)
                    }
                }
            }
            if (outFile.exists() && outFile.length() > 0) outFile.absolutePath else null
        } catch (_: Exception) {
            null
        }
    }

    private fun captureClipboardImagePath(): String? {
        return try {
            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = cm.primaryClip ?: return null
            if (clip.itemCount == 0) return null
            val uri = clip.getItemAt(0).uri ?: return null
            val mime = contentResolver.getType(uri) ?: ""
            if (mime.startsWith("image/") || clip.description.hasMimeType("image/*")) {
                copyUriToCache(uri, "clip")
            } else null
        } catch (_: Exception) {
            null
        }
    }

    private fun getRecentScreenshotPath(): String? {
        if (!hasMediaPermission()) return null
        return try {
            val cutoffSec = (System.currentTimeMillis() / 1000L) - (30 * 60)
            val projection = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATE_ADDED
            )
            val selection = "${MediaStore.Images.Media.DATE_ADDED} >= ? AND LOWER(${MediaStore.Images.Media.DISPLAY_NAME}) LIKE ?"
            val selectionArgs = arrayOf(cutoffSec.toString(), "%screenshot%")
            val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
            contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID))
                    val uri = Uri.withAppendedPath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toString())
                    return copyUriToCache(uri, "ss_$id")
                }
            }
            null
        } catch (_: Exception) {
            null
        }
    }

    private fun commitImagePath(path: String, ic: android.view.inputmethod.InputConnection?): String {
        if (path.isEmpty() || ic == null) return "FAILED"
        val file = File(path)
        if (!file.exists()) return "MISSING"
        return try {
            val uri = FileProvider.getUriForFile(this, "${packageName}.fileprovider", file)
            val mime = if (path.endsWith(".png", true)) "image/png" else "image/jpeg"
            val info = currentEditorInfo
            val supportedTypes = if (info != null) EditorInfoCompat.getContentMimeTypes(info) else emptyArray()
            val acceptsImage = supportedTypes.any {
                ClipDescription.compareMimeTypes(mime, it) || it == "image/*" || it == "*/*"
            }
            if (info != null && acceptsImage) {
                val contentInfo = InputContentInfoCompat(
                    uri,
                    ClipDescription("Nox Clipboard Image", arrayOf(mime)),
                    null
                )
                val ok = InputConnectionCompat.commitContent(
                    ic,
                    info,
                    contentInfo,
                    InputConnectionCompat.INPUT_CONTENT_GRANT_READ_URI_PERMISSION,
                    null
                )
                if (ok) return "COMMITTED"
            }
            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            cm.setPrimaryClip(ClipData.newUri(contentResolver, "Nox Image", uri))
            "COPIED_ONLY"
        } catch (_: Exception) {
            "FAILED"
        }
    }

    override fun onDestroy() {
        try {
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (_: Exception) {}
        flutterView?.detachFromFlutterEngine()
        inputContainer?.removeAllViews()
        flutterView = null
        inputContainer = null
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDestroy()
    }
}

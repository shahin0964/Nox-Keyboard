package com.Nox.Keyboard

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import org.json.JSONObject
import java.io.BufferedReader
import java.io.File
import java.io.FileOutputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

class OtaUpdateManager(private val context: Context) {
    private val appContext = context.applicationContext
    private val prefs = appContext.getSharedPreferences("nox_ota_prefs", Context.MODE_PRIVATE)
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        const val RELEASE_API_URL = "https://api.github.com/repos/shahin0964/Nox-Keyboard/releases/latest"
        const val CHANNEL_ID = "nox_app_updates"
        const val NOTIF_ID_AVAILABLE = 4001
        const val NOTIF_ID_UPDATED = 4002
        const val KEY_LAST_CHECK_MS = "last_check_ms"
        const val KEY_LAST_NOTIFIED_TAG = "last_notified_tag"
        const val KEY_PENDING_APK_PATH = "pending_ota_apk_path"
        const val KEY_PENDING_VERSION = "pending_ota_version"
        const val KEY_AUTO_CHECK = "auto_check_enabled"
    }

    fun getOtaDir(): File {
        val dir = File(appContext.cacheDir, "ota_updates")
        if (!dir.exists()) dir.mkdirs()
        return dir
    }

    fun getInstalledVersionName(): String {
        return try {
            val pInfo = appContext.packageManager.getPackageInfo(appContext.packageName, 0)
            pInfo.versionName ?: "1.0.0"
        } catch (_: Exception) {
            "1.0.0"
        }
    }

    fun isAutoCheckEnabled(): Boolean = prefs.getBoolean(KEY_AUTO_CHECK, true)

    fun setAutoCheckEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_AUTO_CHECK, enabled).apply()
    }

    fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.packageManager.canRequestPackageInstalls()
        } else true
    }

    fun openInstallPermissionSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                data = Uri.parse("package:${appContext.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            appContext.startActivity(intent)
        }
    }

    /**
     * Automatically cleans up downloaded OTA APKs once the update is installed
     * (or when the installed version already matches/exceeds the pending APK).
     */
    fun cleanupAfterInstallIfNeeded(forceCleanAll: Boolean = false) {
        try {
            val installed = getInstalledVersionName()
            val pendingPath = prefs.getString(KEY_PENDING_APK_PATH, null)
            val pendingVer = prefs.getString(KEY_PENDING_VERSION, null)

            if (forceCleanAll || (pendingVer != null && compareSemVer(installed, pendingVer) >= 0)) {
                if (!pendingPath.isNullOrEmpty()) {
                    try {
                        File(pendingPath).delete()
                    } catch (_: Exception) {}
                }
                getOtaDir().listFiles()?.forEach { f ->
                    if (f.name.endsWith(".apk", true)) {
                        try {
                            f.delete()
                        } catch (_: Exception) {}
                    }
                }
                prefs.edit()
                    .remove(KEY_PENDING_APK_PATH)
                    .remove(KEY_PENDING_VERSION)
                    .apply()
            }
        } catch (_: Exception) {}
    }

    fun onPackageReplaced() {
        cleanupAfterInstallIfNeeded(forceCleanAll = true)
        val installed = getInstalledVersionName()
        showNotification(
            id = NOTIF_ID_UPDATED,
            title = "Nox Keyboard Updated (v$installed)",
            body = "Successfully installed and cleaned up update installer.",
            targetRoute = "/updates"
        )
    }

    fun checkIfDueBackground(minIntervalMs: Long = 3 * 60 * 60 * 1000L) {
        if (!isAutoCheckEnabled()) return
        val lastCheck = prefs.getLong(KEY_LAST_CHECK_MS, 0L)
        val now = System.currentTimeMillis()
        if (now - lastCheck < minIntervalMs) return
        checkForUpdate(notifyIfNew = true, onComplete = null)
    }

    fun checkForUpdate(
        notifyIfNew: Boolean = true,
        onComplete: ((Map<String, Any>) -> Unit)? = null
    ) {
        Thread {
            val currentVer = getInstalledVersionName()
            try {
                val conn = (URL(RELEASE_API_URL).openConnection() as HttpURLConnection).apply {
                    requestMethod = "GET"
                    connectTimeout = 10000
                    readTimeout = 10000
                    setRequestProperty("Accept", "application/vnd.github+json")
                    setRequestProperty("User-Agent", "NoxKeyboard-Android/$currentVer")
                }

                val code = conn.responseCode
                if (code !in 200..299) {
                    conn.disconnect()
                    postResult(onComplete, mapOf(
                        "success" to false,
                        "error" to "Server returned HTTP $code",
                        "currentVersion" to currentVer,
                        "hasUpdate" to false
                    ))
                    return@Thread
                }

                val body = BufferedReader(InputStreamReader(conn.inputStream)).use { it.readText() }
                conn.disconnect()

                val json = JSONObject(body)
                val tag = json.optString("tag_name", "").trim()
                val releaseName = json.optString("name", tag)
                val releaseNotes = json.optString("body", "")
                val cleanRemote = tag.removePrefix("v").removePrefix("V").trim()

                var apkUrl = ""
                var apkSize = 0L
                val assets = json.optJSONArray("assets")
                if (assets != null) {
                    for (i in 0 until assets.length()) {
                        val asset = assets.getJSONObject(i)
                        val name = asset.optString("name", "")
                        if (name.endsWith(".apk", ignoreCase = true)) {
                            apkUrl = asset.optString("browser_download_url", "")
                            apkSize = asset.optLong("size", 0L)
                            break
                        }
                    }
                }

                val hasUpdate = cleanRemote.isNotEmpty() &&
                    apkUrl.isNotEmpty() &&
                    compareSemVer(cleanRemote, currentVer) > 0

                prefs.edit().putLong(KEY_LAST_CHECK_MS, System.currentTimeMillis()).apply()

                if (hasUpdate && notifyIfNew) {
                    val lastNotified = prefs.getString(KEY_LAST_NOTIFIED_TAG, "") ?: ""
                    if (lastNotified != tag) {
                        prefs.edit().putString(KEY_LAST_NOTIFIED_TAG, tag).apply()
                        showNotification(
                            id = NOTIF_ID_AVAILABLE,
                            title = "Nox Keyboard $tag Update Available!",
                            body = "Tap to download and install the latest features.",
                            targetRoute = "/updates"
                        )
                    }
                }

                postResult(onComplete, mapOf(
                    "success" to true,
                    "currentVersion" to currentVer,
                    "latestVersion" to cleanRemote,
                    "tagName" to tag,
                    "releaseName" to releaseName,
                    "releaseNotes" to releaseNotes,
                    "apkUrl" to apkUrl,
                    "apkSize" to apkSize,
                    "hasUpdate" to hasUpdate
                ))
            } catch (e: Exception) {
                postResult(onComplete, mapOf(
                    "success" to false,
                    "error" to (e.message ?: "Network error"),
                    "currentVersion" to currentVer,
                    "hasUpdate" to false
                ))
            }
        }.start()
    }

    fun downloadAndInstall(
        apkUrl: String,
        versionTag: String,
        onProgress: (percent: Int, downloaded: Long, total: Long) -> Unit,
        onFinished: (status: String, message: String) -> Unit
    ) {
        if (!canRequestPackageInstalls()) {
            onFinished("PERMISSION_REQUIRED", "Install permission required")
            return
        }

        Thread {
            try {
                var currentUrl = apkUrl
                var conn: HttpURLConnection? = null
                for (hop in 0..5) {
                    val c = (URL(currentUrl).openConnection() as HttpURLConnection).apply {
                        instanceFollowRedirects = true
                        connectTimeout = 15000
                        readTimeout = 30000
                        setRequestProperty("User-Agent", "NoxKeyboard-Android")
                    }
                    val status = c.responseCode
                    if (status in 300..399) {
                        val loc = c.getHeaderField("Location")
                        c.disconnect()
                        if (loc.isNullOrEmpty()) break
                        currentUrl = loc
                    } else {
                        conn = c
                        break
                    }
                }

                if (conn == null || conn.responseCode !in 200..299) {
                    val errCode = conn?.responseCode ?: -1
                    conn?.disconnect()
                    mainHandler.post { onFinished("FAILED", "Download failed (HTTP $errCode)") }
                    return@Thread
                }

                val totalBytes = conn.contentLengthLong
                val safeTag = versionTag.replace(Regex("[^a-zA-Z0-9._-]"), "_")
                val outFile = File(getOtaDir(), "NoxKeyboard-$safeTag.apk")
                if (outFile.exists()) outFile.delete()

                var downloaded = 0L
                var lastReportMs = 0L

                conn.inputStream.use { input ->
                    FileOutputStream(outFile).use { output ->
                        val buffer = ByteArray(16384)
                        while (true) {
                            val read = input.read(buffer)
                            if (read == -1) break
                            output.write(buffer, 0, read)
                            downloaded += read
                            val now = System.currentTimeMillis()
                            if (now - lastReportMs > 120) {
                                lastReportMs = now
                                val pct = if (totalBytes > 0) ((downloaded * 100L) / totalBytes).toInt().coerceIn(0, 100) else 0
                                mainHandler.post { onProgress(pct, downloaded, totalBytes) }
                            }
                        }
                    }
                }
                conn.disconnect()

                mainHandler.post { onProgress(100, downloaded, totalBytes) }

                val cleanVer = versionTag.removePrefix("v").removePrefix("V").trim()
                prefs.edit()
                    .putString(KEY_PENDING_APK_PATH, outFile.absolutePath)
                    .putString(KEY_PENDING_VERSION, cleanVer)
                    .apply()

                val uri = FileProvider.getUriForFile(
                    appContext,
                    "${appContext.packageName}.fileprovider",
                    outFile
                )

                val installIntent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "application/vnd.android.package-archive")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }

                mainHandler.post {
                    try {
                        appContext.startActivity(installIntent)
                        onFinished("INSTALLING", "Installer launched")
                    } catch (e: Exception) {
                        onFinished("FAILED", e.message ?: "Could not launch installer")
                    }
                }
            } catch (e: Exception) {
                mainHandler.post { onFinished("FAILED", e.message ?: "Download error") }
            }
        }.start()
    }

    private fun postResult(cb: ((Map<String, Any>) -> Unit)?, data: Map<String, Any>) {
        if (cb != null) {
            mainHandler.post { cb(data) }
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(
                    CHANNEL_ID,
                    "App Updates",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Notifications when a new Nox Keyboard version is released"
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun showNotification(id: Int, title: String, body: String, targetRoute: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ContextCompat.checkSelfPermission(appContext, Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED
                ) {
                    return
                }
            }
            ensureChannel()
            val intent = Intent(appContext, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("targetRoute", targetRoute)
            }
            val pi = PendingIntent.getActivity(
                appContext,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notif = NotificationCompat.Builder(appContext, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true)
                .setContentIntent(pi)
                .build()

            val nm = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(id, notif)
        } catch (_: Exception) {}
    }

    fun compareSemVer(v1: String, v2: String): Int {
        val p1 = v1.removePrefix("v").removePrefix("V").split(".").map { it.toIntOrNull() ?: 0 }
        val p2 = v2.removePrefix("v").removePrefix("V").split(".").map { it.toIntOrNull() ?: 0 }
        val maxLen = maxOf(p1.size, p2.size)
        for (i in 0 until maxLen) {
            val a = if (i < p1.size) p1[i] else 0
            val b = if (i < p2.size) p2[i] else 0
            if (a != b) return a.compareTo(b)
        }
        return 0
    }
}

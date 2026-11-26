package com.Nox.Keyboard

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sin

/**
 * Zero-latency built-in keyboard SoundPool engine synthesizing crisp PCM click sounds
 * so keypress audio works reliably even when Android's system touch sounds are muted.
 */
class KeySoundEngine(context: Context) {
    private val appContext = context.applicationContext
    private var soundPool: SoundPool? = null
    private val soundIds = mutableMapOf<String, Int>()
    private var initialized = false

    fun init() {
        if (initialized) return
        initialized = true
        try {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            soundPool = SoundPool.Builder()
                .setMaxStreams(8)
                .setAudioAttributes(attrs)
                .build()

            val dir = File(appContext.cacheDir, "nox_sounds")
            if (!dir.exists()) dir.mkdirs()

            Thread {
                try {
                    val styles = listOf("soft", "mechanical", "bubble", "typewriter")
                    for (style in styles) {
                        val file = File(dir, "$style.wav")
                        if (!file.exists() || file.length() < 100) {
                            writeWav(file, style)
                        }
                        val id = soundPool?.load(file.absolutePath, 1) ?: 0
                        if (id > 0) {
                            soundIds[style] = id
                        }
                    }
                } catch (_: Exception) {}
            }.start()
        } catch (_: Exception) {}
    }

    fun play(style: String, volume: Float, effect: Int) {
        try {
            if (!initialized) init()
            val pool = soundPool ?: return
            val id = soundIds[style] ?: soundIds["soft"] ?: return
            val vol = volume.coerceIn(0.05f, 1.0f)
            val rate = if (effect == 1) 0.85f else 1.0f
            pool.play(id, vol, vol, 1, 0, rate)
        } catch (_: Exception) {}
    }

    fun release() {
        try {
            soundPool?.release()
            soundPool = null
            soundIds.clear()
            initialized = false
        } catch (_: Exception) {}
    }

    private fun writeWav(outFile: File, style: String) {
        val sampleRate = 44100
        val durationSec = when (style) {
            "mechanical" -> 0.032
            "typewriter" -> 0.038
            "bubble" -> 0.030
            else -> 0.022
        }
        val numSamples = (sampleRate * durationSec).toInt()
        val samples = ShortArray(numSamples)

        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            val env = when (style) {
                "mechanical" -> exp(-t * 170.0)
                "typewriter" -> exp(-t * 135.0)
                "bubble" -> exp(-t * 145.0)
                else -> exp(-t * 240.0)
            }
            val wave = when (style) {
                "mechanical" -> {
                    val click = sin(2.0 * PI * 1850.0 * t) * 0.55 +
                        sin(2.0 * PI * 420.0 * t) * 0.45
                    val bottomOut = if (t > 0.008) sin(2.0 * PI * 260.0 * (t - 0.008)) * 0.4 else 0.0
                    click + bottomOut
                }
                "typewriter" -> {
                    sin(2.0 * PI * 2400.0 * t) * 0.5 +
                        sin(2.0 * PI * 760.0 * t) * 0.35 +
                        sin(2.0 * PI * 290.0 * t) * 0.35
                }
                "bubble" -> {
                    val freq = 480.0 + 480.0 * (t / durationSec)
                    sin(2.0 * PI * freq * t) * 0.9
                }
                else -> {
                    // Clean muted soft click (Gboard feel)
                    val freq = 750.0 - 450.0 * (t / durationSec)
                    sin(2.0 * PI * freq * t) * 0.75 + sin(2.0 * PI * 220.0 * t) * 0.25
                }
            }
            val v = (wave * env * 22000.0).toInt().coerceIn(-32767, 32767)
            samples[i] = v.toShort()
        }

        val byteData = ByteArray(numSamples * 2)
        ByteBuffer.wrap(byteData).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().put(samples)

        val totalDataLen = byteData.size + 36
        val header = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN).apply {
            put("RIFF".toByteArray())
            putInt(totalDataLen)
            put("WAVE".toByteArray())
            put("fmt ".toByteArray())
            putInt(16) // PCM chunk size
            putShort(1) // AudioFormat = PCM
            putShort(1) // Mono
            putInt(sampleRate)
            putInt(sampleRate * 2) // ByteRate
            putShort(2) // BlockAlign
            putShort(16) // BitsPerSample
            put("data".toByteArray())
            putInt(byteData.size)
        }.array()

        FileOutputStream(outFile).use { fos ->
            fos.write(header)
            fos.write(byteData)
        }
    }
}

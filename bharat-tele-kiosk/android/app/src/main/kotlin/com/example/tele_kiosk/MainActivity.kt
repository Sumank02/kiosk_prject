package com.example.tele_kiosk

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import android.provider.Settings
import android.os.Build
import android.app.ActivityManager
import android.util.Log

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep the app in kiosk mode by requesting lockTask when possible.
        // We'll call startLockTask in onResume to try to lock.
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tele_kiosk/update").setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val path = (call.argument<String>("path"))
                    if (path.isNullOrEmpty()) {
                        result.error("INVALID_PATH", "APK path is null/empty", null)
                    } else {
                        try {
                            installApk(path)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_FAILED", e.localizedMessage, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        try {
            startLockTask()
        } catch (e: Exception) {
            Log.w("MainActivity", "startLockTask failed: ${e.localizedMessage}")
        }
    }

    // Helper to launch an APK install (used by Flutter via method channel if needed).
    fun installApk(filePath: String) {
        val file = File(filePath)
        if (!file.exists()) return
        val uri: Uri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.provider", file)
        val intent = Intent(Intent.ACTION_VIEW)
        intent.setDataAndType(uri, "application/vnd.android.package-archive")
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}

package com.nolumia.rewardpoints

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler(::handleMethodCall)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            SHARE_FILE_METHOD -> shareFile(call, result)
            else -> result.notImplemented()
        }
    }

    private fun shareFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType")
        val chooserTitle = call.argument<String>("chooserTitle")
        val text = call.argument<String>("text")
        val subject = call.argument<String>("subject")

        if (path.isNullOrBlank() || mimeType.isNullOrBlank() || chooserTitle.isNullOrBlank()) {
            result.error("invalid_args", "path/mimeType/chooserTitle は必須です", null)
            return
        }

        val file = File(path)
        if (!file.exists()) {
            result.error("file_not_found", "共有対象ファイルが存在しません: $path", null)
            return
        }

        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            clipData = android.content.ClipData.newRawUri(file.name, uri)

            if (!text.isNullOrBlank()) {
                putExtra(Intent.EXTRA_TEXT, text)
            }
            if (!subject.isNullOrBlank()) {
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
        }

        val chooser = Intent.createChooser(intent, chooserTitle)
        startActivity(chooser)
        result.success("success")
    }

    private companion object {
        const val CHANNEL_NAME = "com.nolumia.rewardpoints/share"
        const val SHARE_FILE_METHOD = "shareFile"
    }
}

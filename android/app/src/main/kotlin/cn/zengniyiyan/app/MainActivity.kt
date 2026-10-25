package cn.zengniyiyan.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "cn.zengniyiyan.app/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val text = call.argument<String>("text")
                        if (text.isNullOrEmpty()) {
                            result.error("BAD_ARGS", "text is required", null)
                        } else {
                            shareText(text)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun shareText(text: String) {
        try {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
            }
            startActivity(Intent.createChooser(intent, "分享一言"))
        } catch (_: Exception) {
        }
    }
}

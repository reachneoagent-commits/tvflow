package com.tvflow.app

import android.app.UiModeManager
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tvflow/device").setMethodCallHandler { call, result ->
            if (call.method == "isTv") {
                val ui = getSystemService(UI_MODE_SERVICE) as UiModeManager
                val pm = packageManager
                val tv = ui.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
                    pm.hasSystemFeature("android.software.leanback") ||
                    pm.hasSystemFeature("amazon.hardware.fire_tv")
                result.success(tv)
            } else {
                result.notImplemented()
            }
        }
    }
}

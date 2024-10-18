package com.cakewallet.cupcake

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.cakewallet.cupcake/key"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSigningKey") {
                val signingKey = getSigningKey()
                if (signingKey != null) {
                    result.success(signingKey)
                } else {
                    result.error("UNAVAILABLE", "Signing key not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getSigningKey(): String? {
        return try {
            val packageInfo: PackageInfo
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                val signatures = packageInfo.signingInfo.apkContentsSigners
                if (signatures.isNotEmpty()) {
                    val md = MessageDigest.getInstance("SHA-1")
                    val publicKey = md.digest(signatures[0].toByteArray())
                    return Base64.encodeToString(publicKey, Base64.DEFAULT)
                }
            } else {
                @Suppress("DEPRECATION")
                packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                val signatures = packageInfo.signatures
                if (signatures.isNotEmpty()) {
                    val md = MessageDigest.getInstance("SHA-1")
                    val publicKey = md.digest(signatures[0].toByteArray())
                    return Base64.encodeToString(publicKey, Base64.DEFAULT)
                }
            }
            null
        } catch (e: Exception) {
            Log.e("MainActivity", "Error getting signing key: ${e.message}")
            null
        }
    }
}


package cn.frcc00.frappupdate

import android.app.Activity
import android.content.Context
import android.os.Environment
import android.os.Looper
import com.vector.update_app.HttpManager
import com.vector.update_app.UpdateAppBean
import com.vector.update_app.utils.AppUpdateUtils
import com.vector.update_app_kotlin.check
import com.vector.update_app_kotlin.updateApp
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import okhttp3.*
import org.json.JSONObject
import java.io.File
import java.io.IOException
import android.widget.Toast



class FrappupdatePlugin: MethodCallHandler {
  var activity : Activity = Activity()
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "frappupdate")
      val frappupdatePlugin = FrappupdatePlugin()
      frappupdatePlugin.activity = registrar.activity()
      channel.setMethodCallHandler(frappupdatePlugin)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "checkUpdate") {
      checkUpdate(activity,call.arguments as String)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  private fun checkUpdate(_context: Context, updateUrl:String) {
    val path = Environment.getExternalStorageDirectory().absolutePath
    activity.updateApp(updateUrl, UpdateHttpManager { callback -> activity.runOnUiThread(callback)}){
      isPost = false
    }.check {
      parseJson {
        val jsonObject = JSONObject(it)
        var update = "No"
        if (jsonObject.optString("version") > AppUpdateUtils.getVersionName(_context)){
          update = "Yes"
        }
        UpdateAppBean()
                //（必须）是否更新Yes,No
                .setUpdate(update)
                //（必须）新版本号，
                .setNewVersion(jsonObject.optString("newVersion"))
                //（必须）下载地址
                .setApkFileUrl(jsonObject.optString("apkFileUrl"))
                //（必须）更新内容
                .setUpdateLog(jsonObject.optString("update_log"))
                //大小，不设置不显示大小，可以不设置
                .setTargetSize(jsonObject.optString("targetSize"))
                //是否强制更新，可以不设置
                .setConstraint(jsonObject.optBoolean("constraint"))
                //设置md5，可以不设置
                .setNewMd5(jsonObject.optString("newMd5"))

      }
    }
  }

  class UpdateHttpManager(@Transient private val runOnUiThread: (() -> Unit) -> Unit) : HttpManager {

    @Transient private val mOkHttpClient = OkHttpClient.Builder().build()

    override fun download(url: String, path: String, fileName: String, callback: HttpManager.FileCallback) {
      callback.onBefore()
      mOkHttpClient.newCall(Request.Builder().url(url).build()).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
          runOnUiThread {
            callback.onError(e.message)
          }
          //Looper.prepare()
          //callback.onError(e.message)
        }
        override fun onResponse(call: Call, response: Response) {
          val code = response.code()
          if (response.code() !in 200..299) callback.onError("$code:${response.message()}") else {
            val body = response.body() ?: return
            val file = File(path).apply {
              if (exists()) delete()
              createNewFile()
            }
            val length = body.contentLength()
            val w = file.outputStream().buffered()
            var downloadLength = 0
            body.byteStream()?.use {
              val r = it.buffered()
              val buffer = ByteArray(2048)
              do {
                val read = r.read(buffer)
                if (read > 0) w.write(buffer, 0, read)
                downloadLength += read
                if (length > 0) runOnUiThread { callback.onProgress(downloadLength.toFloat() / length.toFloat(), length) }
              } while (read >= 0)
            }
            w.close()
            runOnUiThread { callback.onResponse(file) }
          }
        }
      })
    }

    override fun asyncGet(url: String, params: MutableMap<String, String>, callBack: HttpManager.Callback) {
      mOkHttpClient.newCall(Request.Builder().url("$url?${params.keys.joinToString("&") { "$it=${params[it]}" }}").build()).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) = callBack.onError(e.message)
        override fun onResponse(call: Call, response: Response) = response.applyCallback(callBack)
      })
    }

    override fun asyncPost(url: String, params: MutableMap<String, String>, callback: HttpManager.Callback) {
      mOkHttpClient.newCall(Request.Builder().url(url).method("POST",
              FormBody.Builder().apply { params.forEach { add(it.key, it.value) } }.build())
              .build()).enqueue(object : Callback {

        override fun onFailure(call: Call, e: IOException) = callback.onError(e.message)
        override fun onResponse(call: Call, response: Response) = response.applyCallback(callback)

      })
    }

    private fun Response.applyCallback(callback: HttpManager.Callback) {
      val code = code()
      val body = body()?.string()
      android.util.Log.e("check update", "$body")
      if (code in 200..299) callback.onResponse(body) else callback.onError("$code:${message()}")
    }

  }
}

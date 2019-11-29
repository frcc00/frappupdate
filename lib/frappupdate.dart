import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class FrAppUpdateVersionModel {
  String version; //版本
  String updateLog; //更新说明
  String downloadUrl; //下载地址
  String apkSize; //apk大小，字符串，直接传可阅读格式
  bool constraint; //是否强制更新

  String ipaVersion; //ios版本 default to version
  String ipaUpdateLog; //ios 更新说明 default to updateLog
  String ipaDownloadUrl; //ios下载地址
  bool ipaConstraint; //ios是否强制更新 default to constraint

  static FrAppUpdateVersionModel fromMap(map) {
    FrAppUpdateVersionModel model = FrAppUpdateVersionModel();
    model.version = map["version"];
    model.updateLog = map["updateLog"];
    model.downloadUrl = map["downloadUrl"];
    model.apkSize = map["apkSize"];
    model.constraint = map["constraint"];
    model.ipaVersion = map["ipaVersion"];
    model.ipaDownloadUrl = map["ipaDownloadUrl"];
    model.ipaConstraint = map["ipaConstraint"];
    model.ipaUpdateLog = map['ipaUpdateLog'];
    return model;
  }
}

class FrAppUpdate {

  static String newVersionString = '发现新版本';
  static String confirmBtnString = '更新';
  static String cancelBtnString = '取消';

  static Future<bool> checkUpdate(String remoteVersion) async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    Version local = Version.parse(localVersion);
    Version remote = Version.parse(remoteVersion);
    return remote > local;
  }

  static Future<String> getLocalVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  //response must be json
  //{"version":"1.0.0","updateLog":"updateLog","downloadUrl":"downloadUrl",
  // "apkSize":"apkSize","constraint":true,"ipaVersion":"ipaVersion",
  // "ipaDownloadUrl":"ipaDownloadUrl","ipaConstraint":false,"ipaUpdateLog":"ipaUpdateLog"}
  static checkUpdateFromUrl(BuildContext context, String url,{String method='get'/*get or post*/,Future<bool> Function(bool needUpDate) plug, Future<Map> Function(Map response) onResponse}) async{
    var httpClient = new HttpClient();
    var request = method=='get' ? await httpClient.getUrl(Uri.parse(url)):await httpClient.postUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    print(responseBody);
    var responseData = json.decode(responseBody);
    FrAppUpdateVersionModel model;
    if(onResponse != null){
      var data = await onResponse(responseData);
      model = FrAppUpdateVersionModel.fromMap(data);
    }else{
      model = FrAppUpdateVersionModel.fromMap(responseData);
    }
    var plugResult = true;
    if(defaultTargetPlatform == TargetPlatform.iOS){
      var needIpaUpdate = await checkUpdate(model.ipaVersion??model.version);
      if(plug != null){
        plugResult = await plug(needIpaUpdate);
      }
    }else{
      var needIpaUpdate = await checkUpdate(model.version);
      if(plug != null){
        plugResult = await plug(needIpaUpdate);
      }
    }
    if(plugResult == true){
      showUpdateView(context, model);
    }
  }

  static OverlayEntry _entry;
  static double _progressValue=-1;

  static showUpdateView(BuildContext context, FrAppUpdateVersionModel model,{Function(Error) onError}) async{
    _progressValue = -1;
    _entry = OverlayEntry(
        builder: (context){
          return SizedBox.expand(
            child: Material(
              color: Colors.black45,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: IntrinsicHeight(
                  child: StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset('image/lib_update_app_top_bg.png',package: 'frappupdate',width: 250,),
                          Container(
                            color: Colors.white,
                            constraints: BoxConstraints(
                                maxHeight: 300,
                                minWidth: 100
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Text('$newVersionString',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
                                Text('${defaultTargetPlatform == TargetPlatform.iOS?(model.ipaVersion??model.version):model.version}',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
                                Text('${defaultTargetPlatform == TargetPlatform.iOS?"":(model.apkSize??'')}'),
                                Expanded(child: SingleChildScrollView(child: Align(alignment: Alignment.topLeft,child: Text('${defaultTargetPlatform == TargetPlatform.iOS?(model.ipaUpdateLog??model.updateLog):model.updateLog}',textAlign: TextAlign.left,)))),
                                _progressValue>=0?LinearProgressIndicator(value: _progressValue,):Column(
                                  children: <Widget>[
                                    OutlineButton(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('$confirmBtnString'),
                                        ],
                                      ), onPressed: () {
                                        setState((){_progressValue=0;});
                                        confirmAction(model,(val){
                                          var pVal = double.tryParse(val.toString())??_progressValue;
                                          if(pVal > 0){
                                            setState((){_progressValue=pVal/100.0;});
                                          }
                                        },(e){
                                          if(onError!=null){
                                            onError(e);
                                          }
                                        });
                                      },
                                    ),
                                    defaultTargetPlatform == TargetPlatform.iOS?(model.ipaConstraint??model.constraint):model.constraint==true?Container():OutlineButton(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('$cancelBtnString'),
                                        ],
                                      ), onPressed: () {
                                        _entry.remove();
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
    );

    try{
      _entry.remove();
    }catch(_){}

    Overlay.of(context).insert(_entry);
  }

  static confirmAction(FrAppUpdateVersionModel model,Function onProgress,Function onError) async{
    if(defaultTargetPlatform == TargetPlatform.iOS){
      launch(model.ipaDownloadUrl);
    }else{
      try {
        OtaUpdate().execute(model.downloadUrl).listen(
              (OtaEvent event) {
            print('EVENT: ${event.status} : ${event.value}');
            if(event.status == OtaStatus.DOWNLOADING){
              if(onProgress != null){
                onProgress(event.value);
              }
            }
            if(event.status == OtaStatus.INSTALLING){
              _progressValue = -1;
            }
          },
        );
      } catch (e) {
        print('Failed to make OTA update. Details: $e');
        onError(e);
      }
    }
  }
}

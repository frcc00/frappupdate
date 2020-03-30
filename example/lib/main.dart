import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:frappupdate/frappupdate.dart';

void main() => runApp(MaterialApp(
  themeMode: ThemeMode.dark,
  theme: ThemeData(
    brightness: Brightness.light
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark
  ),
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0),(){
      initPlatformState();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var model = FrAppUpdateVersionModel();
    model.downloadUrl = 'http://61.153.141.146:444/sy/file-service/file/get?fileType=AUDIO&path=ship-app-service%2Fapp-release2.1.7.apk';
    model.updateLog = '大版本更新\n1、修复了bug\n2、修复了bug';
    model.constraint = false;
    model.apkSize = '35.8M';
    model.version = '6.6.6';
    FrAppUpdate.showUpdateView(context, model);
//    FrAppUpdate.checkUpdateFromUrl(context, 'http://61.153.141.146:444/sy/app-service/version/getVersion',plug: (needUpDate)async{
//      if(needUpDate==false){
//        print('updated');
//      }
//      return needUpDate;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,

      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}

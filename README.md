# frappupdate
this is a packaging code.
many thanks to version, package_info, path_provider, ota_update, url_launcher

## Getting Started

![avatar](https://github.com/frcc00/frappupdate/blob/master/screenshot/Screen%20Shot%202019-11-28%20at%208.22.46%20PM.png)

```
FrAppUpdate.checkUpdateFromUrl(context, 'http://61.153.141.146:444/sy/app-service/version/getVersion',plug: (needUpDate)async{
   if(needUpDate==false){
     print('updated');
   }
   return needUpDate;
});
```

or

```
var model = FrAppUpdateVersionModel();
model.downloadUrl = 'http://61.153.141.146:444/sy/file-service/file/get?fileType=AUDIO&path=ship-app-service%2Fapp-release2.1.7.apk';
model.updateLog = '大版本更新\n1、修复了bug\n2、修复了bug';
model.constraint = true;
model.apkSize = '35.8M';
model.version = '6.6.6';
FrAppUpdate.showUpdateView(context, model);
```


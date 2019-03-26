# frappupdate

A new Flutter plugin.

#Android only


添加依赖

```
dependencies {
    implementation 'com.android.support:appcompat-v7:27.1.1'
}
```


将MainActivity的父类改为FlutterFragmentActivity
```
class MainActivity: FlutterFragmentActivity() {
}
```


使用
```
Frappupdate.check(updateUrl.json);
```

```
{
    "version": "1.1.0", //比本地版本大，就启动升级。
    "newVersion": "1.0.0", //新版本号
    "apkFileUrl": "https://*****.com/*****/1.0.0/app-release.apk",
    "update_log": "常规更新",
    "targetSize": "10MB",
    "newMd5": "123456",
    "constraint": true //是否强制更新
}
```

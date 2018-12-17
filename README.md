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
Frappupdate.check(updateUrl);
```

```
{
    "version": 1,
    "newVersion": "1.0.0", //比本地版本大，就启动升级。
    "apkFileUrl": "https://github.com/LiHang941/btoken-update-manager/releases/download/1.0.0/app-release.apk",
    "update_log": "常规更新",
    "targetSize": "10MB",
    "newMd5": "123456",
    "constraint": true
}
```
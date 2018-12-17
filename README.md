# frappupdate

A new Flutter plugin.


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
# frappupdate

A new Flutter plugin.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

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
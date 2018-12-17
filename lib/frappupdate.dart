import 'dart:async';

import 'package:flutter/services.dart';

class Frappupdate {
  static const MethodChannel _channel =
      const MethodChannel('frappupdate');

  static check(String updateUrl) async {
     _channel.invokeMethod('checkUpdate',updateUrl);
  }
}

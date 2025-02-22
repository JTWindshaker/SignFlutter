import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sign/app/main_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (!Platform.isAndroid && !Platform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sign/app/main_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('es', null);

  runApp(const MainApp());
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:timezone/data/latest.dart' as tz;

import 'splash_screen.dart';

void main() {
  // tz.initializeTimeZones();
  GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Stockbit Chat Test',
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.tealAccent,
        splashColor: Colors.teal,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.teal,
            primary: Colors.white,
          ),
        ),
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      //Go To SplashScreen First
      home: SplashScreen(),
    );
  }
}

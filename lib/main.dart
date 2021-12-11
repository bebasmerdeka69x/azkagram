import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart' as hivedb;
import 'core/sign.dart';
import 'core/main.dart';

void main() async {
  await hivedb.Hive.initFlutter();
  hivedb.Box<dynamic> box = await hivedb.Hive.openBox("azkagram");

  // setstatus bar transparant
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  List user = box.get('user', defaultValue: []);
  if (user.isNotEmpty) {
    for (var i = 0; i < user.length; i++) {
      // ignore: non_constant_identifier_names
      Map loop_data = user[i];
      if (loop_data["sign"]) {
        runApp(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MainPage(
              box: box,
              userData: loop_data,
            ),
          ),
        );
      }
    }
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SignPage(box: box),
      ),
    );
  } else {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SignPage(box: box),
      ),
    );
  }
}

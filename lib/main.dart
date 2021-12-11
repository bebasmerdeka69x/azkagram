import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart' as hivedb;
import 'pages/main.dart';
import 'pages/sign.dart';

void main() async {
  await hivedb.Hive.initFlutter();
  hivedb.Box<dynamic> box = await hivedb.Hive.openBox("azkagram");

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
            home: MainHomePage(box: box, userData: loop_data,),
          ),
        );
      }
    }
  } else {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SignPage(box: box),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart' as hivedb;
import 'config.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.box, required this.userData})
      : super(key: key);

  final hivedb.Box<dynamic> box;
  final Map userData;

  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        if (constraints.maxWidth < widthMobile) {
          // start script mobile body
          return const Scaffold(
            body: Center(
              child: Text("hello"),
            ),
          );
        } else {
          // start script desktop body
          return const Scaffold(
            body: Center(
              child: Text("hello"),
            ),
          );
        }
        
      },
    );
  }
}

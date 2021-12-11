import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart' as hivedb;
import 'config.dart';

class SignPage extends StatefulWidget {
  const SignPage({Key? key, required this.box}) : super(key: key);
  
  final hivedb.Box<dynamic> box;

  @override
  SignState createState() => SignState();

}

class SignState extends State<SignPage> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   
    return LayoutBuilder(
      builder: (context, constraints) {

        if (constraints.maxWidth < widthMobile) {

        } else {

        }
        return Scaffold();
      },
    );

  }

}

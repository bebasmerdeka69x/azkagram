// ignore_for_file: non_constant_identifier_names, unused_local_variable, use_build_context_synchronously, duplicate_ignore, dead_code

library azkagram;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hidable/hidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:telegram_client/telegram_client.dart';
import 'package:simulate/simulate.dart';
import 'package:path_provider/path_provider.dart';

bool is_debug = false;
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory appSupport = await getApplicationSupportDirectory();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  Hive.init(appSupport.path);
  debug(appSupport.path);
  Box<dynamic> box = await Hive.openBox('telegram_client');
  Widget typePage;
  List users = box.get("users", defaultValue: []);
  for (var i = 0; i < users.length; i++) {
    var loop_data = users[i];
    if (loop_data is Map && loop_data["is_sign"] is bool && loop_data["is_sign"]) {
      Tdlib tg = Tdlib("libtdjson.so", {
        'database_directory': "${appSupport.path}/$i/",
        'files_directory': "${appSupport.path}/$i/",
      });
      tg.on("update", (UpdateTd update) {
        try {
          if (update.raw["@type"] is String) {
            var type = update.raw["@type"];
            if (type == "error") {
              if (RegExp(r"^Can't lock file", caseSensitive: false).hasMatch(update.raw["message"])) {
                if (kDebugMode) {
                  print("eror");
                }
                exit(1);
              }
            }
          }
        } catch (e) {
          debug(e);
        }
      });
      await tg.initIsolate();
      typePage = MainPage(box: box, get_me: loop_data, tg: tg);
      return runSimulate(
        home: typePage,
        debugShowCheckedModeBanner: false,
      );
    }
  }
  Tdlib tg = Tdlib("libtdjson.so", {
    'database_directory': "${appSupport.path}/${(users.isEmpty) ? 0 : users.length + 1}/",
    'files_directory': "${appSupport.path}/${(users.isEmpty) ? 0 : users.length + 1}/",
  });

  tg.on("update", (UpdateTd update) {
    try {
      if (update.raw["@type"] is String) {
        var type = update.raw["@type"];
        if (type == "error") {
          if (RegExp(r"^Can't lock file", caseSensitive: false).hasMatch(update.raw["message"])) {
            if (kDebugMode) {
              print("eror");
            }
            exit(1);
          }
        }
      }
    } catch (e) {
      debug(e);
    }
  });

  await tg.initIsolate();
  typePage = SignPage(box: box, tg: tg);
  return runSimulate(
    home: typePage,
    debugShowCheckedModeBanner: false,
  );
}

class SignPage extends StatefulWidget {
  final Box box;
  final Tdlib tg;
  const SignPage({Key? key, required this.box, required this.tg}) : super(key: key);

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  late Tdlib tg;
  late String status_tdlib = "helo";
  late bool is_no_connection = false;
  dynamic getValue(key, {dynamic defaultValue}) {
    try {
      return widget.box.get(key, defaultValue: defaultValue);
    } catch (e) {
      return defaultValue;
    }
  }

  setValue(key, value) {
    return widget.box.put(key, value);
  }

  late int counts = 0;
  late Map<dynamic, dynamic> state_data;
  final TextEditingController codeTextController = TextEditingController();
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final TextEditingController tokenBotTextController = TextEditingController();
  final TextEditingController fullnameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController newpasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      tg = widget.tg;
    });
    counts = getValue("count", defaultValue: 0);
    Map<String, dynamic> state_data_sign_default = {"username": "", "password": "", "type_page": "signin", "is_verified": "", "secret_word": "", "words": "", "add_secret_word": []};
    try {
      state_data = getValue("state_data_sign", defaultValue: state_data_sign_default);
    } catch (e) {
      setValue("state_data_sign", state_data_sign_default);
      state_data = state_data_sign_default;
    }
    usernameTextController.text = state_data["username"];
    passwordTextController.text = state_data["password"];
    tg.on("update", (UpdateTd update) {
      try {
        if (update.raw["@type"] is String) {
          var type = update.raw["@type"];

          if (type == "updateAuthorizationState") {
            if (update.raw["authorization_state"] is Map) {
              var authStateType = update.raw["authorization_state"]["@type"];
              if (authStateType == "authorizationStateWaitPhoneNumber") {
                setState(() {
                  state_data["type_page"] = "signin";
                  setValue("state_data_sign", state_data);
                });
              }
              if (authStateType == "authorizationStateWaitCode") {
                setState(() {
                  state_data["type_page"] = "code";
                  setValue("state_data_sign", state_data);
                });
              }
              if (authStateType == "authorizationStateWaitPassword") {
                setState(() {
                  state_data["type_page"] = "password";
                });
              }
              if (authStateType == "authorizationStateReady") {
                setState(() {
                  state_data["type_page"] = "main_menu";
                  setValue("state_data_sign", state_data);
                });
              }

              if (authStateType == "authorizationStateClosing") {}

              if (authStateType == "authorizationStateClosed") {}

              if (authStateType == "authorizationStateLoggingOut") {}
            }
          }
          if (type == "updateConnectionState") {
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {
              if (is_no_connection = false) {
                setState(() {
                  is_no_connection = true;
                });
              }
            }
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {}
          }
          if (type == "error") {
            if (update.raw["message"] == "Unauthorized") {}
          }
        }
      } catch (e) {
        debug(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool is_potrait = MediaQuery.of(context).orientation == Orientation.portrait;
    debug(state_data["type_page"]);
    showPopUp(titleName, valueBody) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titleName),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(valueBody ?? "Error"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Mengerti'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    showLoaderDialog() {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const ScaffoldSimulate(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    return ScaffoldSimulate(
      backgroundColor: const Color.fromARGB(255, 235, 234, 255),
      body: LayoutBuilder(builder: (BuildContext ctx, constraints) {
        Widget type_sign_page = Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                usernameTextController.clear();
                passwordTextController.clear();
                state_data["type_page"] = "signin";
                setValue("state_data_sign", state_data);
              });
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
        List<Widget> usernameField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: usernameTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[a-z]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi username dengan benar ya! contoh: azka";
                    }
                    if (kDebugMode) {
                      print(text);
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'username',
                    labelText: "Username",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.profile_2user,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> phoneNumberField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: phoneNumberTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan angka ya!";
                    }
                    if (text.length < 5) {
                      return "Tolong isi dengan benar ya!";
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '62xxxxxxxxx',
                    labelText: "Phone Number",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> tokenBotField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: tokenBotTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]+:[a-zA-Z0-9_-]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan benar ya";
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '1234567890:abbcdefghijklmnopqrstuvwxyz',
                    labelText: "Token Bot",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> codeField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: codeTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan benar ya";
                    }
                    if (text.length != 5) {
                      return "Panjang code harus 5";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '12345',
                    labelText: "Code",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> passwordField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: passwordTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    if (kDebugMode) {
                      print(text);
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'password1234',
                    labelText: "Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.key,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> newpasswordField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: newpasswordTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    if (kDebugMode) {
                      print(text);
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'newpassword123',
                    labelText: "New Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.key,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> fullNameField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: fullnameTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    if (kDebugMode) {
                      print(text);
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'fullname',
                    labelText: "Full Name",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.personalcard,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> titlePage(String title, String description) {
          return [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ];
        }

        if (state_data["type_page"] == "signin") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Phone Number", "Please typing your phone number"),
              const SizedBox(
                height: 20,
              ),
              ...phoneNumberField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("setAuthenticationPhoneNumber", {
                        "phone_number": phoneNumberTextController.text,
                      });

                      debug(res);
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Send Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "signup") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Phone Number", "Please typing your phone number"),
              const SizedBox(
                height: 20,
              ),
              ...phoneNumberField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {},
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Send Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "code") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Account Code", "Tolong kirim kode telegram dari Nomor: ${phoneNumberTextController.text}"),
              const SizedBox(
                height: 20,
              ),
              ...codeField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("checkAuthenticationCode", {
                        "code": codeTextController.text,
                      });
                      var get_me = await tg.getMe();
                      List getUsers = getValue("users", defaultValue: []);
                      for (var i = 0; i < getUsers.length; i++) {
                        var loop_data = getUsers[i];
                        if (loop_data is Map && loop_data["id"] == get_me["result"]["id"]) {
                          getUsers[i]["is_sign"] = true;
                          setValue("users", getUsers);
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => MainPage(
                                box: widget.box,
                                get_me: loop_data,
                                tg: tg,
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      get_me["result"]["is_sign"] = true;
                      getUsers.add(get_me["result"]);
                      setValue("users", getUsers);

                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MainPage(
                            box: widget.box,
                            get_me: get_me,
                            tg: tg,
                          ),
                        ),
                      );

                      return;
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Check Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "password") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Account Password", "Tolong isi password telegram dari Nomor: ${phoneNumberTextController.text}"),
              const SizedBox(
                height: 20,
              ),
              ...passwordField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {},
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Check Password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "signin_token_bot") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Token Bot", "Please confirm your token bot from @botfather"),
              const SizedBox(
                height: 20,
              ),
              ...tokenBotField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("checkAuthenticationBotToken", {
                        "token": tokenBotTextController.text,
                      });
                      var get_me = await tg.getMe();
                      List getUsers = getValue("users", defaultValue: []);
                      for (var i = 0; i < getUsers.length; i++) {
                        var loop_data = getUsers[i];
                        if (loop_data is Map && loop_data["id"] == get_me["result"]["id"]) {
                          getUsers[i]["is_sign"] = true;
                          setValue("users", getUsers);
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => MainPage(
                                box: widget.box,
                                get_me: loop_data,
                                tg: tg,
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      get_me["result"]["is_sign"] = true;
                      getUsers.add(get_me["result"]);
                      setValue("users", getUsers);
                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MainPage(
                            box: widget.box,
                            get_me: get_me,
                            tg: tg,
                          ),
                        ),
                      );

                      return;
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signqr";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn User',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }

        if (is_potrait) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
              child: type_sign_page,
            ),
          );
        } else {
          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              child: Container(
                height: constraints.maxHeight / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/icons/app.png",
                          scale: 5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                          child: type_sign_page,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                    child: type_sign_page,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                    child: type_sign_page,
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

class MainPage extends StatefulWidget {
  final Tdlib tg;
  const MainPage({Key? key, required this.box, required this.get_me, required this.tg}) : super(key: key);
  final Box box;
  final Map get_me;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late Tdlib tg;
  late String status_tdlib = "helo";
  late bool is_no_connection = false;
  final ScrollController scrollController = ScrollController();

  GlobalKey globalKey = GlobalKey();
  late Map get_me_data = {"state": "succes", "sign": true, "token": "", "id": "", "username": "", "first_name": "", "last_name": "", "password": "", "is_verified": true, "secret_word": "", "random_secret_word": ""};
  getValue(key, defaultvalue) {
    try {
      return widget.box.get(key, defaultValue: defaultvalue);
    } catch (e) {
      return defaultvalue;
    }
  }

  setValue(key, value) {
    return widget.box.put(key, value);
  }

  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    super.initState();
    setState(() {
      tg = widget.tg;
    });

    tg.on("update", (UpdateTd update) async {
      try {
        if (!update.raw.containsKey("@extra")) {}
        if (update.raw["@type"] is String) {
          var type = update.raw["@type"];

          if (type == "updateAuthorizationState") {
            if (update.raw["authorization_state"] is Map) {
              var authStateType = update.raw["authorization_state"]["@type"];
              if (authStateType == "authorizationStateWaitPhoneNumber") {}
              if (authStateType == "authorizationStateWaitCode") {}
              if (authStateType == "authorizationStateWaitPassword") {}
              if (authStateType == "authorizationStateReady") {
                bool is_bot = false;
                if (widget.get_me["is_bot"] is bool) {
                  is_bot = widget.get_me["is_bot"];
                }

                if (!is_bot) {
                  tg.debugRequest("getChats", callback: (res) {
                    if (res["ok"]) {
                      var result = res["result"] as List;
                      setValue("chats", result);
                    }
                  });
                }
              }

              if (authStateType == "authorizationStateClosing") {}

              if (authStateType == "authorizationStateClosed") {}

              if (authStateType == "authorizationStateLoggingOut") {}
            }
          }

          if (type == "updateFile") {
            prettyPrintJson(update.raw);
          }

          if (type == "updateConnectionState") {
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {
              setState(() {
                is_no_connection = true;
              });
            }
          }

          var update_api = await update.raw_api;
          if (update_api["update_channel_post"] is Map) {
            var msg = update_api["update_channel_post"];
            var chat_id = msg["chat"]["id"];
            var text = msg["text"];
            var is_outgoing = false;
            if (msg["is_outgoing"] is bool && msg["is_outgoing"]) {
              is_outgoing = msg["is_outgoing"];
            }
            if (text is String && text.isNotEmpty) {
              if (kDebugMode) {
                print(text);
              }
              if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
                return await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
              }
            }
            List chats = getValue("chats", []);
            bool is_found = false;
            for (var i = 0; i < chats.length; i++) {
              var loop_data = chats[i];
              if (loop_data is Map && loop_data["id"] == chat_id) {
                is_found = true;
                chats.removeAt(i);
                Map chat = msg["chat"];
                chats.insert(0, {...chat, "last_message": msg});
                setValue("chats", chats);
              }
            }
            if (!is_found) {
              Map chat = msg["chat"];
              chats.insert(0, {...chat, "last_message": msg});
              setValue("chats", chats);
            }
          }
          if (update_api["update_message"] is Map) {
            var msg = update_api["update_message"];
            var text = msg["text"];
            var caption = msg["caption"];
            var msg_id = msg["message_id"];
            var user_id = msg["from"]["id"];
            var chat_id = msg["chat"]["id"];
            var from_id = msg["from"]["id"];
            var is_outgoing = false;
            if (msg["is_outgoing"] is bool && msg["is_outgoing"]) {
              is_outgoing = msg["is_outgoing"];
            }

            if (text is String && text.isNotEmpty) {
              if (RegExp("/json", caseSensitive: false).hasMatch(text)) {
                return await tg.request("sendMessage", {"chat_id": chat_id, "text": "ID: ${msg["message_id"]}\nApi: ${msg["api_message_id"]}"});
              }
              if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
                return await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
              }
              if (RegExp("/screen", caseSensitive: false).hasMatch(text)) {
                await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
                await Future.delayed(const Duration(microseconds: 1));
                RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

                ui.Image image = await boundary.toImage();
                ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                Uint8List pngBytes = byteData!.buffer.asUint8List();
                var file = File("/home/hexaminate/photo.png");
                await file.writeAsBytes(pngBytes);
                if (kDebugMode) {
                  print("oke");
                }
                await Future.delayed(const Duration(microseconds: 1));
              }
            }
            List chats = getValue("chats", []);
            bool is_found = false;
            for (var i = 0; i < chats.length; i++) {
              var loop_data = chats[i];
              if (loop_data is Map && loop_data["id"] == chat_id) {
                is_found = true;
                chats.removeAt(i);
                Map chat = msg["chat"];
                chats.insert(0, {...chat, "last_message": msg});
                setValue("chats", chats);
              }
            }
            if (!is_found) {
              Map chat = msg["chat"];
              chats.insert(0, {...chat, "last_message": msg});
              setValue("chats", chats);
            }
          }
        }
      } catch (e) {
        debug(e);
      }
    });
  }

  showPopUp([titleName, valueBody]) {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: ScaffoldSimulate(
            backgroundColor: Colors.transparent,
            primary: false,
            body: Builder(builder: (BuildContext context) {
              debug(getValue("count", 1));
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: const Color(0xffF0F8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 100; i++) ...[
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: Text("Hello world"),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  setValue("count", getValue("count", 0) + 1);
                });
              },
              child: const Icon(Iconsax.close_circle),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    tg.debugRequest("getRemoteFile",
        parameters: {build/app/outputs/flutter-apk/app-release.apk
          "remote_file_id": "AwACAgUAAxkBAAN8YqVN653lIV7Zc8_MszVvUBrw6bkAAmQGAAK4CilV3hjjY2xMfoEkBA",
        },
        is_log: true,
        callback: (res) async {});
    tg.debugRequest(
      "sendVideo",
      parameters: {
        "chat_id": 5299353665,
        "video": "/home/hexaminate/Videos/doc_2022-06-11_12-03-29.mp4",
        "caption": "Hello wrld",
      },
      is_log: true,
    );
    // */
    // tg.debugRequest("getChats", is_log: false, parameters: {
    //   "chat_list": {"@type": "chatListMain"},
    //   "chat_id": 2048384079,
    //   "limit": 9,
    //   "messages": [tg.getMessageId(6730), tg.getMessageId(6731)],
    //   "from_messaged_id": tg.getMessageId(6731),
    // }, callback: (res) async {
    //   try {
    //     if (res is Map) {
    //       prettyPrintJson(res, is_log: true);
    //       if (res["@type"] == "messages") {
    //         if (res["messages"] is List) {
    //           List array = [];
    //           for (var i = 0; i < res["messages"].length; i++) {
    //             var loop_data = res["messages"][i];
    //             if (loop_data is Map) {
    //               var update_api = UpdateTd(tg, {
    //                 "@type": "updateNewMessage",
    //                 "message": loop_data,
    //               });
    //               var update = await update_api.raw_api;
    //               if (update["update_channel_post"] is Map) {
    //                 prettyPrintJson(update["update_channel_post"], is_log: true);
    //               }
    //               if (update["update_message"] is Map) {
    //                 prettyPrintJson(update["update_message"], is_log: true);
    //               }
    //             }
    //           }
    //         }
    //       }
    //     }
    //   } catch (e) {}
    // });

    bool is_darkmode = getValue("is_darkmode", false);
    Color color_page = (is_darkmode) ? Colors.black : Colors.white;
    Color color_main = (is_darkmode) ? Colors.white : Colors.black;
    String typePage = getValue("type_page", "home");
    if (typePage == "home") {
      setValue("is_contains_navigation_bar", true);
    }
    String subtypePage = getValue("subtype_page", "brainly");
    int indexPage = getValue("index_page", 0);
    bool is_potrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (typePage == "chat") {
      if (!is_potrait) {
        setValue("is_contains_app_bar", false);
      } else {
        setValue("is_contains_app_bar", true);
      }
    }

    chatAppBar() {
      return Container(
        color: color_page,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: is_potrait,
              child: InkWell(
                child: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  setState(() {
                    setValue("is_contains_app_bar", false);
                    setValue("is_contains_navigation_bar", true);
                    setValue("type_page", "home");
                    setValue("index_page", 0);
                  });
                },
              ),
            ),
            Visibility(
              visible: is_potrait,
              child: const SizedBox(
                width: 10.0,
              ),
            ),
            /*
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey[100],
                          backgroundImage: AssetImage(""),
                        ),
                        */
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              "Hexa-Assistent",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    Widget NavigationBar() {
      List items = [
        {"icon": const Icon(Iconsax.message, color: Colors.black), "title": const Text("Message"), "selectedColor": Colors.black, "type": "home"},
        {"icon": const Icon(Iconsax.game, color: Colors.black), "title": const Text("Games"), "selectedColor": Colors.black, "type": "news"},
        {"icon": const Icon(Iconsax.map, color: Colors.black), "title": const Text("Chat"), "selectedColor": Colors.black, "type": "chat"},
        {"icon": const Icon(Iconsax.profile_2user, color: Colors.black), "title": const Text("Me"), "selectedColor": Colors.black, "type": "me"}
      ];

      Color? selectedItemColor;
      Color? unselectedItemColor;
      double? selectedColorOpacity;

      onTap(int index) {
        if (items[index]["type"] == "home") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "home");
        }
        if (items[index]["type"] == "chat") {
          if (is_potrait) {
            setValue("is_contains_app_bar", true);
          }
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "chat");
        }
        if (items[index]["type"] == "news") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "news");
        }
        if (items[index]["type"] == "settings") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "settings");
        }
        if (items[index]["type"] == "me") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "me");
        }
        setState(() {
          setValue("index_page", index);
        });
      }

      List<Widget> widgetNavigation = items.map((item) {
        return TweenAnimationBuilder<double>(
          tween: Tween(
            end: items.indexOf(item) == indexPage ? 1.0 : 0.0,
          ),
          curve: Curves.easeOutQuint,
          duration: const Duration(milliseconds: 500),
          builder: (context, t, _) {
            final selectedColor = item["selectedColor"] ?? selectedItemColor ?? Theme.of(context).primaryColor;

            final unselectedColor = item["unselectedColor"] ?? unselectedItemColor ?? Theme.of(context).iconTheme.color;

            return Material(
              color: Color.lerp(
                selectedColor.withOpacity(
                  0.0,
                ),
                selectedColor.withOpacity(
                  selectedColorOpacity ?? 0.1,
                ),
                t,
              ),
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: () async {
                  var index_count = items.indexOf(item);
                  onTap.call(index_count);
                },
                customBorder: const StadiumBorder(),
                focusColor: selectedColor.withOpacity(0.1),
                highlightColor: selectedColor.withOpacity(
                  0.1,
                ),
                splashColor: selectedColor.withOpacity(
                  0.1,
                ),
                hoverColor: selectedColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ) -
                      EdgeInsets.only(
                        right: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ).right *
                            t,
                      ),
                  child: Row(
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: Color.lerp(
                            unselectedColor,
                            selectedColor,
                            t,
                          ),
                          size: 24,
                        ),
                        child: items.indexOf(item) == indexPage ? item["activeIcon"] ?? item["icon"] : item["icon"],
                      ),
                      ClipRect(
                        child: SizedBox(
                          height: 20,
                          child: Align(
                            alignment: const Alignment(-0.2, 0.0),
                            widthFactor: t,
                            child: Padding(
                              padding: EdgeInsets.only(left: const EdgeInsets.symmetric(vertical: 10, horizontal: 16).right / 2, right: const EdgeInsets.symmetric(vertical: 10, horizontal: 16).right),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: Color.lerp(selectedColor.withOpacity(0.0), selectedColor, t),
                                  fontWeight: FontWeight.w600,
                                ),
                                child: item["title"],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList();
      return Container(
        constraints: BoxConstraints(
          minWidth: is_potrait ? MediaQuery.of(context).size.width : 0.0,
          minHeight: !is_potrait ? MediaQuery.of(context).size.height : 0.0,
        ),
        padding: const EdgeInsets.all(2),
        child: Material(
          type: MaterialType.card,
          color: Colors.white,
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(20),
          child: is_potrait
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widgetNavigation,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widgetNavigation,
                ),
        ),
      );
    }

    Widget buildSocialLoginButtons() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {},
              heroTag: "browser",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/icons/browser.png"),
              ),
            ),
            FloatingActionButton(
              onPressed: () {},
              heroTag: "telegram",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/icons/telegram.png"),
              ),
            ),
            FloatingActionButton(
              onPressed: () {},
              heroTag: "youtube",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/icons/youtube.png"),
              ),
            ),
          ],
        ),
      );
    }

    return ScaffoldSimulate(
      isShowFrame: true,
      extendBody: true,
      extendBodyBehindAppBar: false,
      backgroundColor: color_page,
      body: ValueListenableBuilder(
        valueListenable: Hive.box('telegram_client').listenable(),
        builder: (context, box, widgets) {
          return LayoutBuilder(
            builder: (BuildContext ctx, constraints) {
              List<Map<String, dynamic>> messages = [
                {"is_outgoing": true, "content": "hello world"},
              ];
              Widget bodyLandscape(Widget mainBody) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(child: NavigationBar()),
                    Expanded(flex: 4, child: mainBody),
                  ],
                );
              }

              debug(typePage);
              if (typePage == "home") {
                List chats = getValue("chats", []);
                Widget bodyHome() {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: const [
                          Text(
                            "AzkaGram",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Iconsax.search_normal,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Channels",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 250.0,
                      child: Builder(builder: (ctx) {
                        var chatChannels = chats.where((res) {
                          if (res["type"] == "channel") {
                            return true;
                          }
                          return false;
                        }).toList();
                        return ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: chatChannels.length,
                          itemBuilder: (BuildContext context, int index) {
                            var nick_name = "";
                            var member_count = "";
                            var path_image = "";
                            if (chatChannels[index]["title"] is String) {
                              nick_name = chatChannels[index]["title"];
                            }
                            if (chatChannels[index]["detail"] is Map) {
                              if (chatChannels[index]["detail"]["member_count"] is int) {
                                member_count = chatChannels[index]["detail"]["member_count"].toString();
                              }
                            }
                            if (nick_name.isEmpty) {
                              print(chatChannels[index]);
                            }
                            var res = chatChannels[index];
                            if (res["profile_photo"] is Map) {
                              if (res["profile_photo"]["path"] is String == false || (res["profile_photo"]["path"] as String).isEmpty) {
                                tg.debugRequest("getRemoteFile",
                                    parameters: {
                                      "remote_file_id": res["profile_photo"]["file_id"],
                                      "priority": 1,
                                    },
                                    is_log: false, callback: (ress) {
                                  if (ress is Map) {
                                    if (ress["local"] is Map) {
                                      if (ress["local"]["path"] is String == false || (ress["local"]["path"] as String).isEmpty) {
                                        tg.debugRequest("downloadFile", parameters: {"file_id": ress["id"], "priority": 1});
                                      }
                                      if (ress["local"]["is_downloading_completed"] is bool && ress["local"]["is_downloading_completed"]) {
                                        for (var i = 0; i < chats.length; i++) {
                                          if (chats[i]["id"] == res["id"]) {
                                            var getPathPhoto = ress["local"]["path"] as String;
                                            if (getPathPhoto.isNotEmpty) {
                                              chats[i]["profile_photo"]["path"] = getPathPhoto;
                                            } else {
                                              if (getPathPhoto.isNotEmpty) {
                                                chats[i]["profile_photo"]["path"] = getPathPhoto;
                                              }
                                            }
                                            print("pke");
                                            // chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                                            print("oke");
                                            setState(() {
                                              setValue("chats", chats);
                                            });
                                          }
                                        }
                                      }
                                    }
                                  }
                                });
                                // tg.debugRequest("getSupergroupFullInfo", is_log: false, parameters: {
                                //   "supergroup_id": int.parse(chatChannels[index]["id"].toString().replaceAll(RegExp(r"-100", caseSensitive: false), "")),
                                // }, callback: (res) {
                                //   try {
                                //     if (res is Map) {
                                //       if (res["photo"] is Map) {
                                //         if (res["photo"]["@type"] == "chatPhoto") {
                                //           if (res["photo"]["sizes"] is List) {
                                //             var getPhoto = res["photo"]["sizes"][res["photo"]["sizes"].length - 1];
                                //             for (var i = 0; i < chats.length; i++) {
                                //               if (chats[i]["id"] == chatChannels[index]["id"]) {
                                //                 var getPathPhoto = getPhoto["photo"]["local"]["path"] as String;
                                //                 if (getPathPhoto.isNotEmpty) {
                                //                   print(getPathPhoto);
                                //                   chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                                //                 } else {
                                //                   if (getPathPhoto.isNotEmpty) {
                                //                     chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                                //                   }
                                //                   tg.debugRequest("downloadFile", parameters: {"file_id": getPhoto["photo"]["id"], "priority": 1});
                                //                 }
                                //                 // chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];

                                //                 setState(() {
                                //                   setValue("chats", chats);
                                //                 });
                                //               }
                                //             }
                                //           }
                                //         }
                                //       }
                                //     }
                                //   } catch (e) {}
                                // });
                              } else if ((res["profile_photo"]["path"] as String).isNotEmpty) {
                                path_image = res["profile_photo"]["path"];
                              }
                            }

                            if (path_image.isNotEmpty) {
                              var file = File(path_image);
                              if (!file.existsSync()) {
                                path_image = "";
                                for (var i = 0; i < chats.length; i++) {
                                  if (chats[i] is Map) {
                                    try {
                                      if (chats[i]["id"] = chatChannels[index]["id"]) {
                                        chats[i]["profile_photo"]["path"] = null;
                                        setValue("chats", chats);
                                      }
                                    } catch (e) {
                                      debug(e);
                                    }
                                  }
                                }
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(1),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    chooseWidget(
                                      isMain: path_image.isNotEmpty,
                                      main: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                                          image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(1),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                      second: Container(
                                        width: 150,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(1),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "no Image",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15,
                                      left: 15,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 2),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: double.infinity,
                                                maxHeight: double.infinity,
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const ui.Color.fromARGB(198, 0, 0, 0),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "live",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 2),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: double.infinity,
                                                maxHeight: double.infinity,
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const ui.Color.fromARGB(197, 131, 131, 131),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                member_count,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 15,
                                      left: 15,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 2),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxWidth: double.infinity,
                                            maxHeight: double.infinity,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const ui.Color.fromARGB(197, 136, 136, 136),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            nick_name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Chats",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...chats.where((res) {
                      if (res["type"] != "channel") {
                        return true;
                      }
                      return false;
                    }).map((res) {
                      var nick_name = "";
                      Map last_message = {};
                      var type_content = "";
                      var message = "";
                      bool isFile = false;
                      var path_image = "";
                      var content = "";

                      if (res["last_message"] is Map && (res["last_message"] as Map).isNotEmpty) {
                        last_message = res["last_message"];
                        if (last_message["type_content"] is String && (last_message["type_content"] as String).isNotEmpty) {
                          type_content = last_message["type_content"];
                        }
                      }
                      if (last_message["caption"] is String) {
                        isFile = true;
                        message = last_message["caption"];
                      }
                      if (last_message["photo"] is List) {
                        isFile = true;
                        var getPhoto = last_message["photo"][last_message["photo"].length - 1];
                        if (getPhoto is Map && (getPhoto["path"] as String).isEmpty) {
                          tg.debugRequest("downloadFile", is_log: false, parameters: {"file_id": getPhoto["id"], "priority": 1}, callback: (ress) {
                            try {
                              if (ress is Map && ress["local"] is Map && ress["local"]["is_downloading_completed"] is bool && ress["local"]["is_downloading_completed"]) {
                                for (var i = 0; i < chats.length; i++) {
                                  if (chats[i]["id"] == res["id"]) {
                                    var getPathPhoto = ress["local"]["path"] as String;
                                    if (getPathPhoto.isNotEmpty) {
                                      chats[i]["last_message"]["photo"][chats[i]["last_message"]["photo"].length - 1]["path"] = getPathPhoto;
                                    } else {
                                      if (getPathPhoto.isNotEmpty) {
                                        chats[i]["last_message"]["photo"][chats[i]["last_message"]["photo"].length - 1]["path"] = getPathPhoto;
                                      }
                                    }

                                    setState(() {
                                      setValue("chats", chats);
                                    });
                                  }
                                }
                              }
                            } catch (e) {}
                          });
                        } else {
                          var file = File(getPhoto["path"]);
                          if (file.existsSync()) {
                            content = getPhoto["path"];
                          } else {
                            for (var i = 0; i < chats.length; i++) {
                              if (chats[i]["id"] == res["id"]) {
                                chats[i]["last_message"]["photo"][chats[i]["last_message"]["photo"].length - 1]["path"] = "";
                                setState(() {
                                  setValue("chats", chats);
                                });
                              }
                            }
                          }
                        }
                      }
                      if (last_message["text"] is String) {
                        message = last_message["text"];
                      }

                      if (kDebugMode) {
                        print(res["id"]);
                      }
                      int unread_count = 0;
                      var date = "";
                      var chat_type = "private";
                      if (res["type"] is String) {
                        chat_type = res["type"];
                      }
                      if (last_message["date"] is int) {
                        date = last_message["date"].toString();
                      }
                      if (res["type"] == "private") {
                        nick_name = res["first_name"];
                      } else {
                        nick_name = res["title"];
                      }
                      if (res["detail"] is Map) {
                        if (res["detail"]["unread_count"] is int) {
                          unread_count = res["detail"]["unread_count"];
                        }
                      }
                      prettyPrintJson(res["profile_photo"], is_log: true);
                      if (res["profile_photo"] is Map) {
                        debug(res);
                        if (res["profile_photo"]["path"] is String == false || (res["profile_photo"]["path"] as String).isEmpty) {
                          debug("sd");
                          tg.debugRequest("getRemoteFile",
                              parameters: {
                                "remote_file_id": res["profile_photo"]["file_id"],
                                "priority": 1,
                              },
                              is_log: false, callback: (ress) {
                            if (ress is Map) {
                              if (ress["local"] is Map) {
                                if (ress["local"]["path"] is String == false || (ress["local"]["path"] as String).isEmpty) {
                                  tg.debugRequest("downloadFile", parameters: {"file_id": ress["id"], "priority": 1});
                                }
                                if (ress["local"]["is_downloading_completed"] is bool && ress["local"]["is_downloading_completed"]) {
                                  for (var i = 0; i < chats.length; i++) {
                                    if (chats[i]["id"] == res["id"]) {
                                      var getPathPhoto = ress["local"]["path"] as String;
                                      if (getPathPhoto.isNotEmpty) {
                                        chats[i]["profile_photo"]["path"] = getPathPhoto;
                                      } else {
                                        if (getPathPhoto.isNotEmpty) {
                                          chats[i]["profile_photo"]["path"] = getPathPhoto;
                                        }
                                      }
                                      print("pke");
                                      // chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                                      print("oke");
                                      setState(() {
                                        setValue("chats", chats);
                                      });
                                    }
                                  }
                                }
                              }
                            }
                          });
                          // tg.debugRequest("getSupergroupFullInfo", is_log: false, parameters: {
                          //   "supergroup_id": int.parse(chatChannels[index]["id"].toString().replaceAll(RegExp(r"-100", caseSensitive: false), "")),
                          // }, callback: (res) {
                          //   try {
                          //     if (res is Map) {
                          //       if (res["photo"] is Map) {
                          //         if (res["photo"]["@type"] == "chatPhoto") {
                          //           if (res["photo"]["sizes"] is List) {
                          //             var getPhoto = res["photo"]["sizes"][res["photo"]["sizes"].length - 1];
                          //             for (var i = 0; i < chats.length; i++) {
                          //               if (chats[i]["id"] == chatChannels[index]["id"]) {
                          //                 var getPathPhoto = getPhoto["photo"]["local"]["path"] as String;
                          //                 if (getPathPhoto.isNotEmpty) {
                          //                   print(getPathPhoto);
                          //                   chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                          //                 } else {
                          //                   if (getPathPhoto.isNotEmpty) {
                          //                     chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];
                          //                   }
                          //                   tg.debugRequest("downloadFile", parameters: {"file_id": getPhoto["photo"]["id"], "priority": 1});
                          //                 }
                          //                 // chats[i]["profile_photos"] = getPhoto["photo"]["local"]["path"];

                          //                 setState(() {
                          //                   setValue("chats", chats);
                          //                 });
                          //               }
                          //             }
                          //           }
                          //         }
                          //       }
                          //     }
                          //   } catch (e) {}
                          // });
                        } else if ((res["profile_photo"]["path"] as String).isNotEmpty) {
                          path_image = res["profile_photo"]["path"];
                        }
                      }

                      if (path_image.isNotEmpty) {
                        var file = File(path_image);
                        if (!file.existsSync()) {
                          path_image = "";
                          for (var i = 0; i < chats.length; i++) {
                            if (chats[i] is Map) {
                              try {
                                if (chats[i]["id"] = res["id"]) {
                                  chats[i]["profile_photo"]["path"] = null;

                                  setValue("chats", chats);
                                }
                              } catch (e) {}
                            }
                          }
                        }
                      }

                      if (isFile) {
                        if (content.isEmpty) {
                          isFile = false;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(1),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: isFile,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(content)).image),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(1),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 15,
                                        right: 15,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxWidth: double.infinity,
                                            maxHeight: double.infinity,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const ui.Color.fromARGB(199, 158, 158, 158),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            chat_type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  chooseWidget(
                                    isMain: path_image.isNotEmpty,
                                    main: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                    ),
                                    second: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        color: Colors.yellow,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(1),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          nick_name[0],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            nick_name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            (date is int) ? date.toString() : "",
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: double.infinity,
                                              maxHeight: double.infinity,
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: const ui.Color.fromARGB(198, 0, 0, 0),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              chat_type,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: double.infinity,
                                              maxHeight: double.infinity,
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: const ui.Color.fromARGB(198, 0, 0, 0),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              (last_message["is_outgoing"] is bool && last_message["is_outgoing"]) ? "Outgoing" : "Incomming",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: message.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      color: ui.Color.fromARGB(255, 48, 48, 48),
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ]);
                }

                return SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: is_potrait ? ConstrainedBox(constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight), child: bodyHome()) : bodyLandscape(bodyHome()),
                );
              }
              if (typePage == "feature") {}
              if (typePage == "chat") {
                Widget bodyChat = Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      /*
                
            image: DecorationImage(
              image: AssetImage(
                "assets/images/nft.jpg",
              ),
              fit: BoxFit.cover,
            ),
            */
                      ),
                  child: Column(
                    children: [
                      Visibility(
                        visible: !is_potrait,
                        child: chatAppBar(),
                      ),
                      Expanded(
                        child: ListView.builder(
                          primary: false,
                          itemCount: messages.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.only(top: 10),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (kDebugMode) {
                                  print("tap");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                  right: 5.0,
                                  left: 5.0,
                                  bottom: 10,
                                ),
                                child: Align(
                                  alignment: (messages[index]["is_outgoing"] ? Alignment.topRight : Alignment.topLeft),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width - 45,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: messages[index]["is_outgoing"]
                                          ? BorderRadius.only(
                                              topRight: Radius.circular((messages.length == (index + 1)) ? 0 : 11),
                                              topLeft: const Radius.circular(11),
                                              bottomRight: Radius.circular((index == 0)
                                                  ? (messages.length == 1)
                                                      ? 11
                                                      : 0
                                                  : 11),
                                              bottomLeft: const Radius.circular(11),
                                            )
                                          : BorderRadius.only(
                                              topRight: const Radius.circular(11),
                                              topLeft: Radius.circular((messages.length == (index + 1)) ? 0 : 11),
                                              bottomRight: const Radius.circular(11),
                                              bottomLeft: Radius.circular((index == 0)
                                                  ? (messages.length == 1)
                                                      ? 11
                                                      : 0
                                                  : 11),
                                            ),
                                      color: (messages[index]["is_outgoing"] ? Colors.blue[200] : Colors.grey.shade200),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      messages[index]["content"],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        constraints: const BoxConstraints(
                          maxHeight: 150.0,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xffFFFFFF),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 0,
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 100,
                          minLines: 1,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                child: const Icon(
                                  Iconsax.happyemoji,
                                  color: Colors.pink,
                                  size: 25,
                                ),
                                onTap: () {},
                              ),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                child: const Icon(
                                  Iconsax.send_1,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                                onTap: () {},
                              ),
                            ),
                            hintText: "Typing here",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {},
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                );
                if (is_potrait) {
                  return bodyChat;
                } else {
                  return bodyLandscape(bodyChat);
                }
              }

              if (typePage == "me") {
                var is_bot = false;
                var nick_name = "";
                var username = "";
                var path_image = "";
                var is_verified = false;
                if (widget.get_me["is_bot"] is bool) {
                  is_bot = widget.get_me["is_bot"];
                }
                if (widget.get_me["username"] is String && (widget.get_me["username"] as String).isNotEmpty) {
                  nick_name = widget.get_me["username"];
                }
                if (widget.get_me["first_name"] is String && (widget.get_me["first_name"] as String).isNotEmpty) {
                  nick_name = widget.get_me["first_name"];
                }
                if (widget.get_me["last_name"] is String && (widget.get_me["last_name"] as String).isNotEmpty) {
                  nick_name += " ${widget.get_me["last_name"]}";
                }
                if (widget.get_me["profile_photo"] is Map) {
                  if (widget.get_me["profile_photo"]["path"] is String) {
                    path_image = widget.get_me["profile_photo"]["path"];
                  }
                }
                if (path_image.isNotEmpty) {
                  var file = File(path_image);
                  if (!file.existsSync()) {
                    path_image = "";
                  }
                }

                if (path_image.isEmpty) {
                  tg.debugRequest("getMe", callback: (res) {
                    prettyPrintJson(res, is_log: true);
                    if (res is Map && res["ok"] is bool && res["ok"] && res["result"] is Map) {
                      var result = res["result"];
                      if (result["profile_photo"] is Map) {
                        if (result["profile_photo"]["path"] is String && (result["profile_photo"]["path"] as String).isNotEmpty) {
                          var getUsers = getValue("users", []);
                          for (var i = 0; i < getUsers.length; i++) {
                            var loop_data = getUsers[i];
                            if (loop_data is Map && loop_data["id"] == result["id"]) {
                              if (loop_data["profile_photo"] is Map == false) {
                                getUsers[i]["profile_photo"] = result["profile_photo"];
                              }
                              getUsers[i]["profile_photo"]["path"] = result["profile_photo"]["path"];
                              setValue("users", getUsers);
                            }
                          }
                        }
                      }
                    }
                  });
                }
                Widget contentListSettings(String title, {required void Function() onPressed, required IconData icon, double? vertical, double? horizontal}) {
                  return MaterialButton(
                    onPressed: onPressed,
                    padding: EdgeInsets.symmetric(horizontal: horizontal ?? 20, vertical: vertical ?? 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(icon),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Iconsax.arrow_right_1),
                      ],
                    ),
                  );
                }

                Widget bodyChat = SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: chooseWidget(
                              isMain: path_image.isNotEmpty,
                              main: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(35)),
                                  image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(1),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                              second: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(35)),
                                  color: Colors.yellow,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(1),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    nick_name[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: username.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: chooseWidget(
                              isMain: true,
                              main: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    nick_name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Icon(
                                    Iconsax.verify5,
                                    color: Colors.blue,
                                  )
                                ],
                              ),
                              second: Text(
                                nick_name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: Column(
                                  children: const [
                                    Text(
                                      "5",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Followings",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  children: const [
                                    Text(
                                      "345",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Fans",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TabBar(
                          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: Colors.black,
                          tabs: const [
                            Tab(
                              text: "Me",
                              icon: Icon(Iconsax.user),
                            ),
                            Tab(
                              text: "Settings",
                              icon: Icon(
                                Iconsax.activity,
                              ),
                            ),
                          ],
                        ),
                        ...[
                          [
                            Center(
                              child: Text("Hello world"),
                            ),
                          ],
                          [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(1),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    contentListSettings("About", onPressed: () {}, icon: Iconsax.book),
                                    contentListSettings("Notes", onPressed: () {}, icon: Iconsax.note),
                                    contentListSettings("Settings", onPressed: () {}, icon: Iconsax.setting),
                                    Row(
                                      children: const [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Divider(),
                                          ),
                                        ),
                                        Text(
                                          "Extra Features",
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Divider(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentListSettings("Automation", onPressed: () {}, icon: Iconsax.mobile_programming),
                                    contentListSettings("Plays", onPressed: () {}, icon: Iconsax.play),
                                    contentListSettings("Story", onPressed: () {}, icon: Iconsax.activity),
                                    contentListSettings("Tools", onPressed: () {}, icon: Iconsax.hierarchy),
                                    Row(
                                      children: const [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Divider(),
                                          ),
                                        ),
                                        Text(
                                          "HexaMinate Integrated app",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Divider(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentListSettings("About HexaMinate", onPressed: () async {}, icon: Iconsax.external_drive),
                                    contentListSettings("Blog", onPressed: () async {}, icon: Iconsax.external_drive),
                                    contentListSettings("Shop", onPressed: () async {}, icon: Iconsax.shop),
                                    contentListSettings("Wallet", onPressed: () async {}, icon: Iconsax.wallet),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ][_tabController.index],
                      ],
                    ),
                  ),
                );
                if (is_potrait) {
                  return bodyChat;
                } else {
                  return bodyLandscape(bodyChat);
                }
              }

              if (is_potrait) {
                return Text(
                  "hello world",
                  style: TextStyle(color: color_main),
                );
              } else {
                return bodyLandscape(Text(
                  "hello world",
                  style: TextStyle(color: color_main),
                ));
              }
            },
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: false,
        child: Builder(builder: (BuildContext ctx) {
          return FloatingActionButton(
            onPressed: () async {},
            child: const Icon(Iconsax.activity),
          );
        }),
      ),
      bottomNavigationBar: Visibility(
        visible: (getValue("is_contains_navigation_bar", true) && is_potrait),
        child: Builder(
          builder: (ctx) {
            return NavigationBar();
            return const Text("keko");
          },
        ),
      ),
    );
  }
}

void debug(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

void debugFunction(Tdlib tg, {required String method, Map<String, dynamic>? parameters, bool is_sync = false, bool is_raw = false}) async {
  try {
    parameters ??= {};
    if (is_sync) {
      debug(tg.invokeSync(method, parameters));
    } else {
      if (is_raw) {
        debug(await tg.invoke(method, parameters));
      } else {
        debug(await tg.request(method, parameters));
      }
    }
  } catch (e) {
    debug(e);
  }
}

List prettyPrintJson(var input, {bool is_log = false}) {
  try {
    if (input is String) {
    } else {
      input = json.encode(input);
    }
    const JsonDecoder decoder = JsonDecoder();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final dynamic object = decoder.convert(input);
    final dynamic prettyString = encoder.convert(object);
    List result = prettyString.split('\n');
    if (is_log) {
      for (var element in result) {
        debug(element);
      }
    }
    return result;
  } catch (e) {
    debug(e);
    return ["error"];
  }
}

void debugPopUp(BuildContext context, var res, {bool is_log = false}) {
  showDialog(
    context: context,
    builder: (context) {
      List results = prettyPrintJson(res, is_log: is_log);
      return Padding(
        padding: const EdgeInsets.all(50),
        child: ScaffoldSimulate(
          backgroundColor: Colors.transparent,
          primary: false,
          body: Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: const Color(0xffF0F8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: results.map((e) {
                      return Text(e);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

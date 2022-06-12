import 'dart:convert';

import 'package:telegram_client/telegram_client.dart';

void main(List<String> args) async {
  var token = "";
  TelegramBotApi tg = TelegramBotApi(token);
  tg.on("update", (UpdateApi update_origin) async {
    var update = update_origin.raw;
    if (update["message"] is Map) {
      var msg = update["message"];

      return await tg.request("sendMessage", {"chat_id": msg["chat"]["id"], "text": json.encode(msg)});
    }
  });
  await tg.initIsolate();
}

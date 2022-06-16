import 'dart:math';

void main() {
  var usernameBokep = ["bokep", "viral", "indo", "indonesia", "hot", "tiktok", "twitter", "baru", "terbaru", "desah", "gadis sma", "janda", "mama muda"];
  var usernameRolePlayer = ["lpm", "rp", "roleplayer", "indonesia", "tiktok", "kp", "fambest", "nsfw", "jamet", "roleplay", "entertainment", "next gen", "club", "bar", "bio", "roleplayer indonesia", "roleplayer asia", "roleplayer kpop", "kpop", "idol", "korea", "anime", "bts", "blackpink", "taehyung", "suga", "jaehyun", "taeyong", "aespa", "roleplayer sandbox", "lpm sandbox"];
  var usernameRl = ["gabut", "cari teman", "indonesia", "anak", "kpop", "fandom", "game", "gta", "iphone"];
  var togel = [
    "judi", "slot", "togel", "online", "indonesia", "terpecaya", "anti scam"
  ];
  print(makeTitle(togel));
}

String makeUsername(List word, {int length = 3, String sparator = "_"}) {
  List words = [];
  while (true) {
    String getRandom = word[Random().nextInt(word.length)].toString().replaceAll(RegExp(r" ", caseSensitive: false), sparator);
    if (words.length >= length) {
      return words.join(sparator);
    }
    if (!words.contains(getRandom)) {
      words.add(getRandom);
    }
  }
}

String makeTitle(List word, {int length = 3, String sparator = " "}) {
  List words = [];
  while (true) {
    String getRandom = word[Random().nextInt(word.length)].toString().replaceAll(RegExp(r"( )+", caseSensitive: false), sparator);
    if (words.length >= length) {
      return words.map((e) {
        var result = "";
        for (var i = 0; i < e.toString().length; i++) {
          if (i == 0) {
            result += e[i].toString().toUpperCase();
          } else {
            result += e[i];
          }
        }
        return result;
      }).join(sparator);
    }
    if (!words.contains(getRandom)) {
      words.add(getRandom);
    }
  }
}

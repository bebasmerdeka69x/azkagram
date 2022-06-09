var token = "1973463091:AAE6_5uPbB4Wc8SX-sbAxYEa8e5oDghORDU";
var telegramUrl = "https://api.telegram.org/bot" + token;
var webAppUrl = "https://script.google.com/macros/s/AKfycbzZEfLYDNJrNwIuEgfECIJRCwzJDFI2HEhCYYm80hz5YtsJzjI/exec";
var ssId = "13zibs5qUGiFhP0pdh-ijBSRp5ntJzg5s4S62ucLr3T4";
var textField = PropertiesService.getScriptProperties();
var text_tg = "";
var tg = new azkadevtelegram.telegram(token);
var tgnotif = new azkadevtelegram.telegram("1992092043:AAFYjhXZXjNqvnlm-B9myALUR0mrh4Wav04");
var db = new minidb.minidb("user");
var idAdminUtama = 1366866241;
var admins = [idAdminUtama];
var username_bot = "Pantura_bot";
var notif_admin_user_ids = [
    1208377372, 1366866241
];
function removeDataArray(array_data, array_remove) {
    var items = array_data;
    var valuesToRemove = array_remove;
    items = items.filter((i) => (valuesToRemove.indexOf(i) === -1));
    return items;
}

function aksesAdmin(data, check_user) {
    if (data.indexOf(check_user) > -1) {
        return true;
    } else {
        return false;
    }
}


function getMe() {
    var url = telegramUrl + "/getMe";
    var response = UrlFetchApp.fetch(url);
    Logger.log(response.getContentText());
}
function getWebhook() {
    var url = telegramUrl + "/getWebhookInfo";
    var response = UrlFetchApp.fetch(url);
    Logger.log(response.getContentText());
}

function getUpdates() {
    var url = telegramUrl + "/getUpdates";
    var response = UrlFetchApp.fetch(url);
    Logger.log(response.getContentText());
}

function setWebhook() {
    var url = telegramUrl + "/setWebhook?url=" + webAppUrl;
    var response = UrlFetchApp.fetch(url);
    Logger.log(response.getContentText());
}

function deleteWebhook() {
    var url = telegramUrl + "/deleteWebhook?url";
    var response = UrlFetchApp.fetch(url);
    Logger.log(response.getContentText());
}
function test() {
    console.log(db.getValue("key:1939179228"));
}
function sendText(id, text, id_msg) {
    var url = telegramUrl + "/sendMessage";

    var payload = {
        "chat_id": id,
        "text": text,
        "parse_mode": "HTML",
        "reply_to_message_id": id_msg
    };

    var options = {
        "method": "POST",
        'contentType': 'application/json',
        "payload": JSON.stringify(payload)
    };

    var response = UrlFetchApp.fetch(url, options);
    Logger.log(response.getContentText());
}

function sendText1() {
    var url = telegramUrl + "/sendMessage";

    var payload = {
        "chat_id": "100313917",
        "text": "aleaa",
        "parse_mode": "HTML"

    };

    var options = {
        "method": "POST",
        "payload": payload,
        "followRedirects": true,
        "muteHttpExceptions": true
    };

    var response = UrlFetchApp.fetch(url, options);
    Logger.log(response.getContentText());
}

function getProp() {
    sendText1(textField.getProperty('field'));
    textField.deleteAllProperties();
}

function doGet(e) {
    return HtmlService.createHtmlOutput("chatt");
}

function doPost(e) {
    var update = JSON.parse(e.postData.contents);
    if (update) {

        try {
            if (update.callback_query) {
                var cb = update.callback_query;
                var cbm = cb.message;
                var user_id = cb.from.id;
                var nama = cb.from.first_name;
                var username = cb.from.username ? "@" + username : "";
                var chat_id = cbm.chat.id;
                var chat_type = cbm.chat.type;
                var msg_id = cbm.message_id;
                var mentionHtml = "<a href='tg://user?id=" + user_id + "'>" + nama + "</a>";
                var mentionMarkdown = "[" + nama + "](tg://user?id=" + user_id + ")";
                var text = cb.data;
                var sub_data = text.replace(/(.*:|=.*)/ig, "");
                var sub_id = text.replace(/(.*=)/ig, "");

                if (RegExp("^user_terbaru$", "i").exec(text)) {
                    var message = getLastUser();
                    var option = {
                        "chat_id": chat_id,
                        "message_id": msg_id,
                        "text": message
                    }
                    return tg.request("editMessageText", option);
                }
                if (RegExp("^add_admin$", "i").exec(text)) {
                    var message = "Silahkan Kirim links ini ke user lainya\nhttps://t.me/" + username_bot + "?start=acces_admin";
                    var option = {
                        "chat_id": chat_id,
                        "message_id": msg_id,
                        "text": message
                    }
                    return tg.request("editMessageText", option);
                }
                if (RegExp("^List_admin$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = false;
                    }
                    if (get) {
                        var message = "Berikut Id admin bot ini\n";
                        message += "ID: " + get.join("\n");
                    } else {
                        var message = "Belum ada admin bot yang di tambahkan"
                    }
                    var option = {
                        "chat_id": chat_id,
                        "message_id": msg_id,
                        "text": message
                    }
                    return tg.request("editMessageText", option);
                }
                if (RegExp("^delete_admin$", "i").exec(text)) {
                    var message = "Silahkan Send Id admin yang akan anda hapus";
                    var value = {
                        "settings": "deleteadmin",
                        "message_id": msg_id
                    }
                    db.setValue("key:" + chat_id, JSON.stringify(value));
                    var option = {
                        "chat_id": chat_id,
                        "message_id": msg_id,
                        "text": message
                    }
                    return tg.request("editMessageText", option);
                }
            }

            if (update.message) {
                var msg = update.message;
                var text = msg.text ? msg.text : false;
                var caption = msg.caption ? msg.caption : false;
                var id = msg.chat.id;
                var from_id = msg.from.id;
                var chat_id = msg.chat.id;
                var user_id = msg.from.id;
                var last_name = msg.from.last_name ? msg.from.last_name : "";
                var username = msg.chat.username;
                var answer = "";
                var name = msg.from.first_name + " " + last_name;
                var id_msg = msg.message_id;
                var mentionHtml = "<a href='tg://user?id=" + user_id + "'>" + name + "</a>";
                var mentionMarkdown = "[" + nama + "](tg://user?id=" + user_id + ")";
                //sendText(id,"Please Wait");//ini untuk jawaban please wait
                SpreadsheetApp.openById(ssId).getSheets()[0].appendRow([new Date(), id, username, name, text, answer]);
                if (text) {
                    var message = "-: " + user_id + "\n-:" + username + "\n-" + mentionHtml + "\n" + text + "";
                    for (let index = 0; index < notif_admin_user_ids.length; index++) {
                        var element = notif_admin_user_ids[index];
                        try {
                            var option = {
                                "chat_id": element,
                                "text": message,
                                "parse_mode": "html"
                            }
                            tgnotif.request("sendMessage", option);
                        } catch (e) {

                        }
                    }
                }



                if (RegExp("^linimasa$", "i").exec(text)) {
                    var pesan = "Masukan nomor handphone yang anda cari";
                    var send = tg.request("sendMessage", { chat_id: id, text: pesan });
                    var message_id = (send.ok) ? send.result.message_id : false;
                    var value = {
                        "settings": "linimasa",
                        "message_id": message_id
                    }
                    db.setValue("key:" + id, JSON.stringify(value));
                    return true;
                }


                if (RegExp("^trace number$", "i").exec(text)) {
                    var pesan = "Masukan nomor handphone yang anda cari untuk mendaptakan <b>IMEI</b> target";
                    var send = tg.request("sendMessage", { chat_id: id, text: pesan, parse_mode: "html" });
                    var message_id = (send.ok) ? send.result.message_id : false;
                    var value = {
                        "settings": "tracenumber",
                        "message_id": message_id
                    }
                    db.setValue("key:" + id, JSON.stringify(value));
                    return true;
                }

                if (RegExp("^trace imei$", "i").exec(text)) {
                    var pesan = "Masukan <b>IMEI</b> yang muncul dari <b>TRACE IMEI</b> untuk mendapatkan nomor target, cek satu persatu";
                    var send = tg.request("sendMessage", { chat_id: id, text: pesan, parse_mode: "html" });

                    var message_id = (send.ok) ? send.result.message_id : false;
                    var value = {
                        "settings": "traceimei",
                        "message_id": message_id
                    }
                    db.setValue("key:" + id, JSON.stringify(value));
                    return true;
                }



                if (RegExp("^Menu Admin$", "i").exec(text)) {
                    if (user_id == idAdminUtama) {
                        var data = {
                            "chat_id": id,
                            "text": "Silahkan Tap menunya kak",
                            "reply_markup": {
                                "inline_keyboard": [
                                    [
                                        {
                                            "text": "Pengguna Terbaru",
                                            "callback_data": "user_terbaru"
                                        },
                                        {
                                            "text": "List Admin",
                                            "callback_data": "list_admin"
                                        }
                                    ],
                                    [
                                        {
                                            "text": "Tambah Admin",
                                            "callback_data": "add_admin"
                                        },
                                        {
                                            "text": "Hapus Admin",
                                            "callback_data": "delete_admin"
                                        }
                                    ]
                                ]
                            }
                        }
                        return tg.request("sendMessage", data);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }

                }



                if (RegExp("^/start acces_admin").exec(text)) {
                    var type = text.replace(/(\/start|\/start )/ig, "");
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": chat_id,
                            "text": "Mohon maaf anda sudah menjadi admin bot ini"
                        }
                        return tg.request("sendMessage", option);
                    } else {
                        admins.push(user_id);
                        db.setValue("admin", JSON.stringify(admins));
                        var option = {
                            "chat_id": idAdminUtama,
                            "text": "Admin baru\nID: " + user_id + "\nNama: " + nama + ""
                        }
                        tg.request("sendMessage", option);
                        var option = {
                            "chat_id": chat_id,
                            "text": "Selamat anda berhasil menjadi admin bot ini"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^SOSMED$", "i").exec(text)) {
                    var option = {
                        "chat_id": id,
                        "text": "Silahkan Send Usernamenya"
                    }
                    var send = tg.request("sendMessage", option);
                    var message_id = (send.ok) ? send.result.message_id : false;
                    var value = {
                        "settings": "username",
                        "message_id": message_id
                    }
                    db.setValue("key:" + id, JSON.stringify(value));
                    return true;
                }

                if (RegExp("^/help|help$", "i").exec(text)) {

                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var pesan = "Selamat datang di menu Bot Ultra Pantura\n\nFITUR : \n==========================\n\nCEKPOS : Menampilkan Posisi Terbaru sesuai koordinat LAC CID pada peta Google Earth beserta sektornya \n\nHPNIK: Menampilkan registrasi Nomor\n\nNIKHP: Menampilkan nomor terdaftar didalam nik\n\nNOPOL : Menampilkan informasi kendaraan berdasarkan nomor polisi\n\nNIK : Menampilkan informasi ktp berdasarkan nomor NIK\n\nNKK: Menampilkan informasi Kartu Keluarga\n\nTRACE IMEI :\nMasukan IMEI yang muncul dari TRACE IMEI untuk mendapatkan nomor target, cek satu persatu\n\nLINIMASA:\nMasukan nomor Telkomsel yang anda cari \n\nTRACE NUMBER:\nMasukan nomor Handphone yang anda cari untuk mendapatkan IMEI target\n\nSOSMED:\nMasukan username otomatis akan mencari akun media sosial \n\nHELP : Menampilkan daftar perintah\n\nHarap hubungi admin jika mengalami kendala @Babi654";
                        var option = {
                            "chat_id": id,
                            "text": pesan,
                            "parse_mode": "html",
                            "reply_to_message_id": id_msg,
                            "reply_markup": {
                                "resize_keyboard": true,
                                "keyboard": [
                                    ["MENU ADMIN", "SOSMED"],
                                    ["CEKPOS", "LINIMASA", "NOPOL"],
                                    ["MSISDN", "KENDARAAN", "EMAIL"],
                                    ["NAMA", "NIK", "KK"],
                                    ["FIRMA", "BPJS", "TRANSAKSI"],
                                    ["HELP"]
                                ]
                            }
                        }
                        return tg.request("sendMessage", option);
                    } else {
                        var data = {
                            "chat_id": id,
                            "text": "Mohon maaf hanya admin yang bisa akses"
                        }
                        return tg.request("sendMessage", data);

                    }
                }

                if (RegExp("^/remove .*").exec(text)) {
                    var textId = text.replace(/(\/remove|\/remove )/ig, "");
                    if (user_id == idAdminUtama) {
                        try {
                            var get = JSON.parse(db.getValue("admin"));
                        } catch (e) {
                            var get = false;
                        }
                        var message = "Mengapus ID: " + Number(textId) + "\ndari Admin";
                        if (typeof get == "object") {
                            var admin = get;
                            var data = removeDataArray(admin, [Number(textId)]);
                            db.setValue("admin", JSON.stringify(data));
                            var option = {
                                "chat_id": chat_id,
                                "text": message
                            }
                            return tg.request("sendMessage", option);
                        } else {
                            var option = {
                                "chat_id": chat_id,
                                "text": message
                            }
                            return tg.request("sendMessage", option);
                        }
                    } else {
                        var option = {
                            "chat_id": chat_id,
                            "text": "Hanya Admin utama yang bisa"
                        }
                        return tg.request("sendMessage", option);

                    }
                }

                if (RegExp("^CEKPOS$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;
                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        SpreadsheetApp.openById(ssId).getSheets()[0].appendRow([new Date(), id, username, name, text, answer]);
                        var textValue = text.split(" ").slice(1).join(" ");
                        var valueField = textValue;
                        var now = new Date();
                        var time = Utilities.formatDate(now, 'Asia/Jakarta', 'HH:mm:ss');
                        var range = unSheet("data", 2, 1, 1);
                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "check",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "SILAHKAN INPUT DATA",
                            "parse_mode": "html"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }

                }
                if (RegExp("^transaksi$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "transaksi",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^bpjs$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "bpjs",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^firma$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "firma",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^MSISDN$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "msisdn",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^KENDARAAN$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "kendaraan",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^email$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "email",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^nama$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "nama",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^hpnik$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "hpnik",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }

                if (RegExp("^nikhp$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "nikhp",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Text"
                        }
                        return tg.request("editMessageText", option);

                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }


                if (RegExp("^nopol$", "i").exec(text)) {

                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }

                        var value = {
                            "settings": "nopol",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input Data nopol"
                        }
                        return tg.request("editMessageText", option);

                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }

                }
                if (RegExp("^nik$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }

                        var value = {
                            "settings": "nik",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input data nik"
                        }
                        return tg.request("editMessageText", option);


                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }
                if (RegExp("^(n)?kk$", "i").exec(text)) {
                    try {
                        var get = JSON.parse(db.getValue("admin"));
                    } catch (e) {
                        var get = idAdminUtama;
                    }
                    var data = (typeof get == "object") ? get.map(data => admins.push(Number(data))) : false;

                    if (aksesAdmin(admins, user_id)) {
                        var option = {
                            "chat_id": id,
                            "text": "Please Wait"
                        }
                        var send = tg.request("sendMessage", option);
                        var message_id = (send.ok) ? send.result.message_id : false;
                        var range = unSheet("data", 2, 1, 1);

                        var rows = range.filter(function (item) {
                            return item[1] === valueField;
                        });
                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n" + dataRow[2];
                            }
                        } else {
                            text_tg += "Please Wait";
                        }
                        var value = {
                            "settings": "nkk",
                            "message_id": message_id
                        }
                        db.setValue("key:" + id, JSON.stringify(value));
                        Utilities.sleep(1000);
                        var option = {
                            "chat_id": id,
                            "message_id": message_id,
                            "text": "Silahkan Input data nkk"
                        }
                        return tg.request("editMessageText", option);
                    } else {
                        var option = {
                            "chat_id": id,
                            "text": "Mohon Maaf hanya khusus admin"
                        }
                        return tg.request("sendMessage", option);
                    }
                }

                if (/^\/.*/ig.exec(text)) {
                    var commandField = text.slice(1).split(" ")[0];
                    if (commandField == "start") {
                        text_tg = "Selamat Datang <b>" + name + "</b>\nID Telegram Anda: <b>" + id + "</b>\nUsername: <b>@" + username + "</b>";
                        text_tg += "\nGunakan \/help untuk bantuan";
                        text_tg += "\n\nHarap ID Telegram anda sudah didaftarkan oleh Admin @Babi654";
                        return sendText(id, text_tg, id_msg);
                    } else if (commandField == "nikhp") {

                    } else if (commandField == "/") {
                        var rows = mySheet("INFO", 2, 1, 2, 0);

                        if (rows.length > 0) {
                            for (var i = 0, l = rows.length; i < l; i++) {
                                var dataRow = rows[i];
                                text_tg += "\n<b>" + dataRow[1] + "</b>";
                            }
                        } else {
                            text_tg += "</b>";
                        }


                    } else {
                        text_tg = "";
                    }
                }

                try {
                    var get = JSON.parse(db.getValue("key:" + id));
                } catch (e) {
                    var get = false;
                }
                if (get) {
                    if (get.message_id) {
                        try {
                            tg.request("deleteMessage", { chat_id: id, message_id: get.message_id });
                        } catch (e) {
                        }
                    }
                    
                    if (get.settings == "msisdn") {
                        if (text) {
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "kendaraan") {
                        if (text) {
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }


                    if (get.settings == "email") {
                        if (text) {
                            if (!RegExp(".*@.*", "i").exec(text)) {

                            var data = {
                                "chat_id": id,
                                "text": "Format email salah tolong ulangin lagi"
                            }
                            return tg.request("sendMessage", data);
                            }
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }


                    if (get.settings == "nama") {
                        if (text) { 
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "firma") {
                        if (text) { 
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "bpjs") {
                        if (text) { 
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "transaksi") {
                        if (text) { 
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }

                    if (get.settings == "check") {
                        if (text) {
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }

                            return tg.request("sendMessage", data);
                        }
                    }


                    if (get.settings == "traceimei") {
                        if (text) {
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "tracenumber") {
                        if (text) {
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }

                    if (get.settings == "linimasa") {
                        if (text) {
                            var message = "Kami Segera Proses permintaan anda";
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }
                    if (get.settings == "username") {
                        if (text) {
                            var message = checkUsername(text.replace(/(@)/ig, ""));
                            var data = {
                                "chat_id": id,
                                "text": message,
                                "parse_mode": "markdown"
                            };
                            tg.request("sendMessage", data);

                            var cariVideo = scrapeYoutube(text, "video")
                            tg.request("sendMessage", { chat_id: id, text: cariVideo, parse_mode: "markdown" });
                            var cariChannel = scrapeYoutube(text, "channel");
                            tg.request("sendMessage", { chat_id: id, text: cariChannel, parse_mode: "markdown" });
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);
                        }
                    }

                    if (get.settings == "hpnik") {
                        if (text) {
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);

                        }
                    }
                    if (get.settings == "nikhp") {
                        if (text) {
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);

                        }
                    }
                    if (get.settings == "nopol") {
                        if (text) {
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);

                        }
                    }
                    if (get.settings == "nik") {
                        if (text) {
                            try {
                                tg.request("deleteMessage", { chat_id: id, message_id: get.message_id });
                            } catch (e) {
                            }
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);

                        }
                    }
                    if (get.settings == "nkk") {
                        if (text) {
                            try {
                                tg.request("deleteMessage", { chat_id: id, message_id: get.message_id });
                            } catch (e) {
                            }
                            var data = {
                                "chat_id": id,
                                "text": "Data " + text + "\n Dimasukan ke database kami"
                            }
                            tg.request("sendMessage", data);
                            db.delete("key:" + id);
                            return true;
                        } else {
                            var data = {
                                "chat_id": id,
                                "text": "tolong kirim pesan berupa text"
                            }
                            return tg.request("sendMessage", data);

                        }
                    }
                }
            }
        } catch (e) {
            var data = {
                "chat_id": 1939179228,
                "text": "Eror " + e.message + ""
            }
            return tg.request("sendMessage", data);

        }
    }
}

function unSheet(sheets, row, column, numRows) {
    var fileSpred = SpreadsheetApp.openById(ssId);
    var sheet = fileSpred.getSheetByName(sheets);
    var range = sheet.getRange(row, column, sheet.getLastRow() - numRows, sheet.getLastColumn()).getDisplayValues();

    return range;
}

function testSheet(sheets, row, column, numColumns, numRows) {
    var fileSpred = SpreadsheetApp.openById(ssId);
    var sheet = fileSpred.getSheetByName(sheets);
    var range = sheet.getRange(row, column, numRows, numColumns).getDisplayValues();

    return range;
}

function mySheet(sheets, row, column, numColumns, numRows) {
    var fileSpred = SpreadsheetApp.openById(ssId);
    var sheet = fileSpred.getSheetByName(sheets);
    var range = sheet.getRange(row, column, sheet.getLastRow() - numRows, numColumns).getDisplayValues();

    return range;
}

function mySheet1(sheets, row, column, numColumns, numRows) {
    var fileSpred = SpreadsheetApp.openById(ssId);
    var sheet = fileSpred.getSheetByName(sheets);
    var range = sheet.getRange(row, column, sheet.getLastRow() - numRows, numColumns).getValues();

    return range;
}

function myUser(id) {
    var userRows = mySheet1("USER", 2, 1, 4, 1);

    userRows = userRows.filter(function (item) {
        return item[0] === id;
    });

    return userRows;
}

function cekUser(id) {
    var countUser = myUser(id).length;

    return countUser;
}

function titleCase(str) {
    //  var splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
        // You do not need to check if i is larger than splitStr length, as your for does that for you
        // Assign it back to the array
        splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);
    }
    // Directly return the joined string
    return splitStr.join(' ');
}

function getLastUser() {
    var sheets = "data";
    var fileSpred = SpreadsheetApp.openById(ssId);
    var sheet = fileSpred.getSheetByName(sheets);;
    var from = (sheet.getLastRow() < 6) ? sheet.getLastRow() : sheet.getLastRow() - 5;
    var range = sheet.getRange("A" + from + ":Z").getValues();
    var message = "Ini Data User Terakhir Chat\n";
    for (var i = 0; i < range.length; i++) {
        var loop_data = range[i];
        if (loop_data[1]) {
            var models = (loop_data[2]) ? "Username: @" + loop_data[2] : "Name: " + loop_data[3];
            message += "ID : " + loop_data[1] + ",\n" + models + "\n";
        }
    }
    return message;
}
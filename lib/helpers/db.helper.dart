import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:jomaboi/helpers/migrations/migrations.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Database? database;

Future<Database> getDBInstance() async {
  if (database == null) {
    Database db;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      db = await databaseFactory.openDatabase(
        "database.db",
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
        ),
      );
    } else {
      String databasesPath = await getDatabasesPath();
      String dbPath = join(databasesPath, 'database.db');
      db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      );
    }
    database = db;
    return db;
  } else {
    return database!;
  }
}

typedef MigrationCallback = Function(Database database);
List<MigrationCallback> migrations = [v1];

void onCreate(Database database, int version) async {
  for (MigrationCallback callback in migrations) {
    await callback(database);
  }
}

void onUpgrade(Database database, int oldVersion, int version) async {
  for (int index = oldVersion; index < version; index++) {
    MigrationCallback callback = migrations[index];
    await callback(database);
  }
}

Future<void> resetDatabase() async {
  Database database = await getDBInstance();
  database.delete("payments", where: "id>0");
  database.delete("accounts", where: "id>0");
  database.delete("categories", where: "id>0");
  database.delete("groups", where: "id>0");

  await database.insert("accounts", {
    "name": "Cash",
    "icon": Icons.wallet.codePoint,
    "color": Colors.teal.value,
    "isDefault": 1
  });

  // prefill all categories
  List<Map<String, dynamic>> categories = [
    {"name": "Housing", "icon": Icons.house.codePoint},
    {"name": "Transportation", "icon": Icons.emoji_transportation.codePoint},
    {"name": "Groceries", "icon": Icons.local_grocery_store.codePoint},
    {"name": "Utilities", "icon": Icons.category.codePoint},
    {"name": "Insurance", "icon": Icons.health_and_safety.codePoint},
    {"name": "Medical & Healthcare", "icon": Icons.medical_information.codePoint},
    {"name": "Investments & Debt Payments", "icon": Icons.attach_money.codePoint},
    {"name": "Personal Spending", "icon": Icons.house.codePoint},
    {"name": "Recreation & Entertainment", "icon": Icons.tv.codePoint},
    {"name": "Miscellaneous", "icon": Icons.library_books_sharp.codePoint},
  ];

  List<Map<String, dynamic>> groups = [
    {"name": "Housing", "icon": Icons.house.codePoint},
    {"name": "Transportation", "icon": Icons.emoji_transportation.codePoint},
    {"name": "Groceries", "icon": Icons.local_grocery_store.codePoint},
    {"name": "Utilities", "icon": Icons.category.codePoint},
    {"name": "Insurance", "icon": Icons.health_and_safety.codePoint},
    {"name": "Medical & Healthcare", "icon": Icons.medical_information.codePoint},
    {"name": "Investments & Debt Payments", "icon": Icons.attach_money.codePoint},
    {"name": "Personal Spending", "icon": Icons.house.codePoint},
    {"name": "Recreation & Entertainment", "icon": Icons.tv.codePoint},
    {"name": "Miscellaneous", "icon": Icons.library_books_sharp.codePoint},
  ];

  int index = 0;
  for (Map<String, dynamic> category in categories) {
    await database.insert("categories", {
      "name": category["name"],
      "icon": category["icon"],
      "color": Colors.primaries[index].value,
    });
    index++;
  }

  int index2 = 0;
  for (Map<String, dynamic> group in groups) {
    await database.insert("groups", {
      "name": group["name"],
      "icon": group["icon"],
      "color": Colors.primaries[index2].value,
    });
    index2++;
  }
}

Future<String> getExternalDocumentPath() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  Directory directory = Directory("");
  if (Platform.isAndroid) {
    directory = Directory("/storage/emulated/0/Download");
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  final exPath = directory.path;
  await Directory(exPath).create(recursive: true);
  return exPath;
}

Future<dynamic> export() async {
  List<dynamic> accounts = await database!.query("accounts");
  List<dynamic> groups = await database!.query("groups");
  List<dynamic> categories = await database!.query("categories");
  List<dynamic> payments = await database!.query("payments");

  Map<String, dynamic> data = {};
  data["accounts"] = accounts;
  data["groups"] = groups;
  data["categories"] = categories;
  data["payments"] = payments;

  final path = await getExternalDocumentPath();
  String name = "jomaboi-backup-${DateTime.now().millisecondsSinceEpoch}.json";
  File file = File('$path/$name');
  await file.writeAsString(jsonEncode(data));
  return file.path;
}

Future<void> import(String path) async {
  File file = File(path);
  Map<int, int> accountsMap = {};
  Map<int, int> categoriesMap = {};
  Map<int, int> groupsMap = {};

  try {
    Map<String, dynamic> data = await jsonDecode(file.readAsStringSync());
    await database!.transaction((transaction) async {
      await transaction.delete("categories", where: "id!=0");
      await transaction.delete("groups", where: "id!=0");
      await transaction.delete("accounts", where: "id!=0");
      await transaction.delete("payments", where: "id!=0");

      List<dynamic> categories = data["categories"];
      List<dynamic> groups = data["groups"];
      List<dynamic> accounts = data["accounts"];
      List<dynamic> payments = data["payments"];

      for (Map<String, dynamic> category in categories) {
        int id0 = category["id"];
        category.remove("id");
        int id = await transaction.insert("categories", category);
        categoriesMap[id0] = id;
      }

      for (Map<String, dynamic> group in groups) {
        int id0 = group["id"];
        group.remove("id");
        int id = await transaction.insert("groups", group);
        groupsMap[id0] = id;
      }

      for (Map<String, dynamic> account in accounts) {
        int id0 = account["id"];
        account.remove("id");
        int id = await transaction.insert("accounts", account);
        accountsMap[id0] = id;
      }

      for (Map<String, dynamic> payment in payments) {
        payment.remove("id");
        payment["account"] = accountsMap[payment["account"]];
        payment["category"] = categoriesMap[payment["category"]];
        await transaction.insert("payments", payment);
      }
      return transaction;
    });
  } catch (err) {
    rethrow;
  }
}
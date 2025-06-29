import 'dart:async';
import 'package:jomaboi/helpers/db.helper.dart';
//import 'package:jomaboi/model/category.model.dart';
import 'package:jomaboi/models/group.model.dart';
import 'package:intl/intl.dart';

class GroupDao {
  Future<int> create(Group group) async {
    final db = await getDBInstance();
    var result = await db.insert("groups", group.toJson());
    return result;
  }

  Future<List<Group>> find({bool withSummery = true}) async {
    final db = await getDBInstance();

    List<Map<String, dynamic>> result;
    if (withSummery) {
      String fields = [
        "c.id",
        "c.name",
        "c.icon",
        "c.color",
        "c.budget",
        "SUM(CASE WHEN t.type='DR' AND t.group=c.id THEN t.amount END) as expense"
      ].join(",");
      DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0);
      DateTime to = DateTime.now().add(const Duration(days: 1));
      DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm");
      String sql = "SELECT $fields FROM groups c "
          "LEFT JOIN payments t ON t.groups = c.id AND t.datetime BETWEEN DATE('${formatter.format(from)}') AND DATE('${formatter.format(to)}') "
          "GROUP BY c.id ";
      result = await db.rawQuery(sql);
    } else {
      result = await db.query("groups");
    }
    List<Group> groups = [];
    if (result.isNotEmpty) {
      groups = result.map((item) => Group.fromJson(item)).toList();
    }
    return groups;
  }

  Future<int> update(Group group) async {
    final db = await getDBInstance();
    var result = await db.update("groups", group.toJson(), where: "id = ?", whereArgs: [group.id]);
    return result;
  }

  Future<int> upsert(Group group) {
    if (group.id != null) {
      return update(group);
    } else {
      return create(group);
    }
  }

  Future<int> delete(int id) async {
    final db = await getDBInstance();
    var result = await db.delete("groups", where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future deleteAll() async {
    final db = await getDBInstance();
    var result = await db.delete("groups");
    return result;
  }
}
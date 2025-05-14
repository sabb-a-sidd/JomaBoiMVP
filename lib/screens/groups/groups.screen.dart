import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/group_dao.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/group.model.dart';
import 'package:fintracker/widgets/dialog/group_form.dialog.dart';

import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupDao _groupDao = GroupDao();
  //final CategoryDao _categoryDao = CategoryDao();
  EventListener? _groupEventListener;
  //List<Category> _categories = [];
  List<Group> _groups = [];

  void loadData() async {
    List<Group> groups = await _groupDao.find();
    setState(() {
      _groups = groups;
      //_categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _groupEventListener = globalEvent.on("group_update", (data) {
      debugPrint("groups are changed");
      loadData();
    });
  }

  @override
  void dispose() {
    _groupEventListener?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Groups",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        body: ListView.separated(
          itemCount: _groups.length,
          itemBuilder: (builder, index) {
            Group group = _groups[index];
            double expenseProgress = (group.expense ?? 0) / (group.budget ?? 0);
            return ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (builder) => GroupForm(
                          group: group,
                        ));
              },
              leading: CircleAvatar(
                backgroundColor: group.color.withOpacity(0.2),
                child: Icon(
                  group.icon,
                  color: group.color,
                ),
              ),
              title: Text(
                group.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: expenseProgress.isFinite
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: expenseProgress,
                        semanticsLabel: expenseProgress.toString(),
                      ),
                    )
                  : Text("No budget",
                      style: Theme.of(context).textTheme.bodySmall?.apply(
                          color: Colors.grey, overflow: TextOverflow.ellipsis)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Container(
              width: double.infinity,
              color: Colors.grey.withAlpha(25),
              height: 1,
              margin: const EdgeInsets.only(left: 75, right: 20),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context, builder: (builder) => const GroupForm());
          },
          child: const Icon(Icons.add),
        ));
  }
}

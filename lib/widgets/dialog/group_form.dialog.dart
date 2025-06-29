import 'package:jomaboi/dao/group_dao.dart';
//import 'package:jomaboi/dao/category_dao.dart';

import 'package:jomaboi/data/icons.dart';
import 'package:jomaboi/events.dart';

import 'package:jomaboi/model/group.model.dart';
//import 'package:jomaboi/model/category.model.dart';

import 'package:jomaboi/widgets/buttons/button.dart';
import 'package:jomaboi/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function();

class GroupForm extends StatefulWidget {
  final Group? group;
  final Callback? onSave;

  const GroupForm({super.key, this.group, this.onSave});

  @override
  State<StatefulWidget> createState() => _GroupForm();
}

class _GroupForm extends State<GroupForm> {
  final GroupDao _groupDao = GroupDao();
  //final CategoryDao _categoryDao = CategoryDao();

  final TextEditingController _nameController = TextEditingController();

  Group _group =
      Group(name: "", icon: Icons.wallet_outlined, color: Colors.pink);
  //Category _category = Category(name: "", icon: Icons.wallet_outlined, color: Colors.pink);

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _group = widget.group ??
          Group(name: "", icon: Icons.wallet_outlined, color: Colors.pink);
    }
  }

  void onSave(context) async {
    await _groupDao.upsert(_group);
    if (widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEvent.emit("group_update");
  }

  void pickIcon(context) async {}
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      title: Text(
        widget.group != null ? "Edit Group" : "New Group",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: _group.color,
                      borderRadius: BorderRadius.circular(40)),
                  alignment: Alignment.center,
                  child: Icon(
                    _group.icon,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: TextFormField(
                  initialValue: _group.name,
                  decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Group name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15)),
                  onChanged: (String text) {
                    setState(() {
                      _group.name = text;
                    });
                  },
                ))
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue:
                    _group.budget == null ? "" : _group.budget.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Budget',
                  hintText: 'Enter budget',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: CurrencyText(null)),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (String text) {
                  setState(() {
                    _group.budget = double.parse(text.isEmpty ? "0" : text);
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //Color picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Colors.primaries.length,
                  itemBuilder: (BuildContext context, index) => Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.5, vertical: 2.5),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _group.color = Colors.primaries[index];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.primaries[index],
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    width: 2,
                                    color: _group.color.value ==
                                            Colors.primaries[index].value
                                        ? Colors.white
                                        : Colors.transparent,
                                  )),
                            )),
                      )),
            ),
            const SizedBox(
              height: 15,
            ),

            //Icon picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppIcons.icons.length,
                  itemBuilder: (BuildContext context, index) => Container(
                      width: 45,
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.5, vertical: 2.5),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _group.icon = AppIcons.icons[index];
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                    color: _group.icon == AppIcons.icons[index]
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2)),
                            child: Icon(
                              AppIcons.icons[index],
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          )))),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          height: 45,
          isFullWidth: true,
          onPressed: () {
            onSave(context);
          },
          color: Theme.of(context).colorScheme.primary,
          label: "Save",
        )
      ],
    );
  }
}

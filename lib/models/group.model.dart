import 'package:flutter/material.dart';

class Group {
  int? id;
  String name;
  IconData icon;
  Color color;
  double? budget;
  double? expense;

  Group(
      {this.id,
      required this.name,
      required this.icon,
      required this.color,
      this.budget,
      this.expense});

  factory Group.fromJson(Map<String, dynamic> data) => Group(
        id: data["id"],
        name: data["name"],
        icon: IconData(data["icon"], fontFamily: 'MaterialIcons'),
        color: Color(data["color"]),
        budget: data["budget"] ?? 0,
        expense: data["expense"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon.codePoint,
        "color": color.value,
        "budget": budget,
      };
}

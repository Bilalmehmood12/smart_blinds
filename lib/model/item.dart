import 'package:flutter/material.dart';
import 'package:smart_blinds/database_helper.dart';

class Item {
  int id;
  String name;
  bool isEnable;
  bool isSchedule;
  TimeOfDay time;
  String img;
  double currentLevel;
  double targetLevel;
  List<bool> weekDays;

  Item({
    this.id,
    this.name,
    this.isEnable = false,
    this.isSchedule = false,
    this.currentLevel = 0,
    this.img = 'res/window.png',
    this.time,
    this.targetLevel = 0,
    this.weekDays
  });

  Map<String, dynamic> toJson() {
    return {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnImg: img,
      DatabaseHelper.columnCLevel: currentLevel,
      DatabaseHelper.columnTLevel: targetLevel,
      DatabaseHelper.columnEnable: isEnable == true ? 1:0,
      DatabaseHelper.columnScheduled: isSchedule == true ? 1:0,
      DatabaseHelper.columnTime: DateTime(2022,1,1,time.hour,time.minute).toIso8601String(),
      DatabaseHelper.columnWeekDays[0]: weekDays[0] == true ? 1:0,
      DatabaseHelper.columnWeekDays[1]: weekDays[1] == true ? 1:0,
      DatabaseHelper.columnWeekDays[2]: weekDays[2] == true ? 1:0,
      DatabaseHelper.columnWeekDays[3]: weekDays[3] == true ? 1:0,
      DatabaseHelper.columnWeekDays[4]: weekDays[4] == true ? 1:0,
      DatabaseHelper.columnWeekDays[5]: weekDays[5] == true ? 1:0,
      DatabaseHelper.columnWeekDays[6]: weekDays[6] == true ? 1:0
    };
  }

  static Item fromJson(Map<String, Object> item) {
    return Item(
        id: item[DatabaseHelper.columnKey],
        name: item[DatabaseHelper.columnName],
        img: item[DatabaseHelper.columnImg],
        currentLevel: item[DatabaseHelper.columnCLevel],
        targetLevel: item[DatabaseHelper.columnTLevel],
        isEnable: item[DatabaseHelper.columnEnable] == 1 ? true : false,
        isSchedule: item[DatabaseHelper.columnScheduled] == 1 ? true : false,
        time: TimeOfDay.fromDateTime(
            DateTime.parse(item[DatabaseHelper.columnTime])),
        weekDays: [
          item[DatabaseHelper.columnWeekDays[0]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[2]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[2]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[3]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[4]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[5]] == 1 ? true : false,
          item[DatabaseHelper.columnWeekDays[6]] == 1 ? true : false
        ]
    );
  }
}